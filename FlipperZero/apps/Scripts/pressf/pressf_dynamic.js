/*
 * == Press F to pay respects ==
 *
 * BadUSB F-key spam - sends the "f" keypress on a randomized delay.
 *
 * The delay is a floor (minimum seconds between presses) plus a random extra
 * amount drawn from [0, randomCoefficient). Both follow gentle exponential
 * curves over an integer step number x (consecutive, starting at 0):
 *     floor(x)       = 1.43489516568 ^ x
 *     randomCoeff(x) = 1.40511582648 ^ x
 * The bases were chosen so that x = 0 -> (1, 1) and the default x = 10 -> (37, 30).
 * x is capped at 50 (51 steps).
 *
 * UI: a submenu with one row per step (0..50). Each row shows the triplet
 * "step, floor, +random avg" with durations in coarse units (s / h / d / y)
 * so long delays stay readable. The physical Up/Down buttons move the cursor
 * down the 51 rows; Center confirms the chosen step (the only way a Flipper JS
 * view is notified of a selection), and Back stops the script.
 *
 * The header is a message channel to the user (not a copy of the selected row):
 *   "First keypress..."            on startup
 *   "Sent 'f', next in <dur>"      every timer tick (live countdown)
 *   "ERROR: BadUSB offline"        when BadUSB is not connected
 *   "Step <x>: <floor> +<avg>"  when a step is confirmed
 * The timer reads the descriptively-named delay values on every tick, so a
 * newly confirmed step takes effect from the next keypress.
 */

let badusb = require("badusb");
let eventLoop = require("event_loop");
let gui = require("gui");
let submenu = require("gui/submenu");
let math = require("math");

// Initialize BadUSB
badusb.setup();

// ---- Delay model ----------------------------------------------------------
// Exponential curve bases (x = 10 lands on 37 / 30, x = 0 on 1 / 1).
const FLOOR_CURVE_BASE = 1.43489516568;     // floor (sec)      = base ^ x
const RANDOM_COEFF_BASE = 1.40511582648;    // random coeff (sec) = base ^ x
const DEFAULT_DELAY_STEP = 10;              // initial x
const MAX_DELAY_STEP = 50;                  // upper cap for x
const DELAY_STEP_COUNT = MAX_DELAY_STEP + 1; // 0..50 inclusive = 51 steps

// Coarse duration unit thresholds (seconds).
const PER_HOUR = 3600;
const PER_DAY = 24 * PER_HOUR;
const PER_YEAR = 365.25 * PER_DAY; // leap-year averaged

// Full-precision curve values, computed once per step. These arrays are the
// authoritative source for both the UI text and the timer (never mutated at
// runtime).
const FLOOR_BY_STEP = [];
const RANDOM_COEFF_BY_STEP = [];
for (let x = 0; x < DELAY_STEP_COUNT; x++) {
    FLOOR_BY_STEP.push(math.pow(FLOOR_CURVE_BASE, x));
    RANDOM_COEFF_BY_STEP.push(math.pow(RANDOM_COEFF_BASE, x));
}

// Descriptively named runtime delay values. Recomputed (from the full-precision
// curves) whenever a new step is confirmed; the timer reads them each tick.
let delayStep = DEFAULT_DELAY_STEP;                                   // current x
let delayFloor = FLOOR_BY_STEP[DEFAULT_DELAY_STEP];                   // floor, in seconds
let randomExtraDelayCoefficient = RANDOM_COEFF_BY_STEP[DEFAULT_DELAY_STEP]; // random range, in seconds

// Next countdown for a delay: the floor plus a random extra drawn from
// [0, coefficient). Defined once so the delay math cannot diverge between
// the commit re-init and the post-press reschedule.
function nextCountdown(delayFloor, randomExtraDelayCoefficient) {
    return math.floor(delayFloor + math.random() * randomExtraDelayCoefficient);
}

// Render a value with at most one decimal, dropping a trailing ".0"
// (e.g. 37 -> "37", 15.5 -> "15.5").
function oneDecimal(v) {
    let tenths = math.floor(v * 10 + 0.5); // round half-up to nearest 0.1
    let whole = math.floor(tenths / 10);
    let frac = tenths % 10;
    if (frac === 0) {
        return whole.toString();
    }
    return whole.toString() + "." + frac.toString();
}

// Format a duration (seconds) in the coarsest unit that keeps it short:
// s below an hour, h below a day, d below a year, y above that.
// e.g. 37 -> "37s", 5760 -> "1.6h", 90000 -> "1.0d", 90000000 -> "2.9y".
function formatDuration(seconds) {
    if (seconds < PER_HOUR) {
        return oneDecimal(seconds) + "s";
    }
    if (seconds < PER_DAY) {
        return oneDecimal(seconds / PER_HOUR) + "h";
    }
    if (seconds < PER_YEAR) {
        return oneDecimal(seconds / PER_DAY) + "d";
    }
    return oneDecimal(seconds / PER_YEAR) + "y";
}

// Zero-pad a step index to two digits (0 -> "00", 7 -> "07", 50 -> "50").
function stepLabel(x) {
    return x < 10 ? "0" + x.toString() : x.toString();
}

// One submenu row: "NN, floor, +random avg". All three values of the
// delay are shown on a single line so the whole delay is visible per step.
// The step is zero-padded to two digits.
function rowLabel(x) {
    return stepLabel(x) + ", " + formatDuration(FLOOR_BY_STEP[x]) + ", +" +
        formatDuration(RANDOM_COEFF_BY_STEP[x] / 2);
}

// ---- View -----------------------------------------------------------------
let state = {
    countdown: 0,
    running: true,
    delayStep: delayStep,
    delayFloor: delayFloor,
    randomExtraDelayCoefficient: randomExtraDelayCoefficient,
    submenuView: null
};

// Show a message in the header (the user-facing message channel).
function showMessage(state, text) {
    if (state.submenuView) {
        state.submenuView.set("header", text);
    }
}

// 51 rows, one per step.
let rows = [];
for (let x = 0; x < DELAY_STEP_COUNT; x++) {
    rows.push(rowLabel(x));
}

state.submenuView = submenu.makeWith(
    { header: "First keypress..." },
    rows
);

// Show the list. The submenu cursor starts at row 0; the active step is the
// one the timer is using (see the "Step N:" header messages once adjusted).
gui.viewDispatcher.switchTo(state.submenuView);

// Center confirms a row -> a new delay step is chosen. Recompute the
// descriptively-named delay values from the full-precision curves and re-init
// the countdown with a FRESH randomized delay, so the new step takes effect
// immediately instead of the old countdown continuing. No keypress is sent
// here -- the key is only sent when the countdown reaches zero on a timer tick.
// The submenu stays visible (Ok does not leave it), so the user can immediately
// keep adjusting with Up/Down.
eventLoop.subscribe(state.submenuView.chosen, function (subscription, index, evLoop, state) {
    state.delayStep = index;
    state.delayFloor = FLOOR_BY_STEP[index];
    state.randomExtraDelayCoefficient = RANDOM_COEFF_BY_STEP[index];
    // Re-init the countdown: floor + a random amount in [0, coefficient).
    state.countdown =
        nextCountdown(state.delayFloor, state.randomExtraDelayCoefficient);
    showMessage(state, "Step " + index.toString() + ": " +
        formatDuration(state.delayFloor) + " +" +
        formatDuration(state.randomExtraDelayCoefficient / 2));
    print("Delay step " + index.toString() + ": floor " + state.delayFloor.toString() +
        "s, +random avg " + (state.randomExtraDelayCoefficient / 2).toString() +
        "s, countdown re-init to " + state.countdown.toString() + "s");
}, eventLoop, state);

// Handle the back navigation button - a DIFFERENT API than the submenu's
// "chosen" contract above. The physical back key fires the view dispatcher's
// "navigation" contract, so it is subscribed to separately.
eventLoop.subscribe(gui.viewDispatcher.navigation, function (subscription, _item, evLoop, state) {
    state.running = false;
    evLoop.stop();
    print("Script stopped by back navigation button.");
}, eventLoop, state);

// Timer callback for countdown
function onTimer(subscription, _item, timerState) {
    if (!timerState.running) return;

    timerState.countdown--;

    if (timerState.countdown <= 0) {
        // Check USB connection before sending key
        if (badusb && badusb.isConnected() && badusb.press) {
            badusb.press(0x09);
            print("Sent 'f' keypress");

            // Next delay = floor + a random amount in [0, coefficient)
            timerState.countdown =
                nextCountdown(timerState.delayFloor, timerState.randomExtraDelayCoefficient);
        } else {
            // Show error but keep retrying in 1 second
            print("BadUSB not connected - cannot send keys");
            showMessage(timerState, "ERROR: BadUSB offline");
            timerState.countdown = 1;
            return [timerState];
        }
    }

    // Refresh the header with the live countdown every second.
    showMessage(timerState, "Sent 'f', next in " + formatDuration(timerState.countdown));
    print("Next press in " + timerState.countdown.toString() + " seconds");

    // Return updated state for event loop
    return [timerState];
}

// Subscribe to periodic timer every 1000ms
// Initial countdown = 0 for immediate first keypress
eventLoop.subscribe(eventLoop.timer("periodic", 1000), onTimer, state);

// Run event loop
print("F-key spam started. Up/Down to adjust delay, Center to commit, back to stop.");
eventLoop.run();

// Cleanup
print("Script stopped.");
badusb.quit();
