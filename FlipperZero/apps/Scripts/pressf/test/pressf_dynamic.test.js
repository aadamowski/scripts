#!/usr/bin/env node
/*
 * Momentum mock test harness for pressf_dynamic.js
 *
 * Executes the REAL pressf_dynamic.js against faithful mocks of the Momentum (mJS)
 * runtime and asserts the delay model + control flow:
 *   - delay curves (floor = 1.43489516568^x, coeff = 1.40511582648^x)
 *   - default step 10 -> (37, 30); step 0 -> (1, 1); cap at step 50
 *   - 51-row submenu (one per step), each row a "NN, floor, +avg" triplet
 *     (step zero-padded to two digits) with durations in coarse units (s/h/d/y)
 *   - header acts as a message channel: "First keypress...", "Sent 'f', next in …"
 *     (refreshed every timer tick with the live countdown), "Step …",
 *     "ERROR: BadUSB offline" (not a duplicate of a row label)
 *   - timer uses the committed delay values; presses the F key (0x09)
 *   - back navigation stops the loop and runs badusb.quit()
 *
 * Run: node test/pressf_dynamic.test.js
 *
 * The Momentum JS GUI has no view that emits discrete physical Up/Down key
 * events; the submenu is the vehicle that uses physical Up/Down to move a
 * selection cursor, with Center (Ok) confirming. This harness models that
 * contract: chosen(index) fires when a row is confirmed.
 */
const vm = require("vm");
const fs = require("fs");
const path = require("path");
const assert = require("assert");

const scriptSrc = fs.readFileSync(path.join(__dirname, "..", "pressf_dynamic.js"), "utf8");

// Delay-curve bases (mirrors pressf_dynamic.js). Hoisted to the top so the
// independent re-derivation in sections 5b/7 can reference them anywhere.
const FLOOR_BASE = 1.43489516568;
const RAND_BASE = 1.40511582648;

// ---- Recorded side effects -------------------------------------------------
const calls = { setup: 0, quit: 0, presses: [] };
const printLog = [];
let stopped = false;
let currentView = null;
const timers = [];
const headerUpdates = [];   // every .set("header", ...) the script performs
const reinitCountdowns = []; // state.countdown captured right after each "chosen" commit
let stateObj = null;        // shared state object the script passes to handlers
let tickCount = 0;
let pumpQueue = [];
let badusbConnected = true; // toggled per pump event to exercise the error path

// ---- Mock views ------------------------------------------------------------
let initialHeader = null;   // captured at view creation, before run()
function makeView(header, rows) {
    initialHeader = header;
    const view = {
        __kind: "submenu",
        header,
        rows,
        chosen: { __contract: true },
        set(name, value) {
            if (name === "header") {
                this.header = value;
                headerUpdates.push(value);
            }
        },
    };
    return view;
}

// Faithful to the JS binding: makeWith({header}, [children...]) -> view.
function makeWith(props, children) {
    return makeView(props ? props.header : "", children || []);
}

// ---- Mock modules ----------------------------------------------------------
const badusb = {
    setup() { calls.setup++; },
    quit() { calls.quit++; },
    isConnected() { return badusbConnected; },
    press(c) { calls.presses.push(c); },
};

// A faithful-enough event loop: run() blocks, pumping scripted events and
// dispatching them to the registered handlers until stop() is called.
// mJS calling convention: handler(subscription, EVENT_VALUE, ...contextArgs)
const eventLoop = {
    _ctx: {},
    subscribe(contract, cb, ...ctx) {
        if (contract && contract.__timer) { eventLoop._ctx.timer = { cb, ctx }; stateObj = ctx[0]; return; }
        if (contract && contract.__nav) { eventLoop._ctx.nav = { cb, ctx }; return; }
        if (contract && contract.__contract) { eventLoop._ctx.chosen = { cb, ctx }; return; }
        throw new Error("unrecognized contract in subscribe");
    },
    timer(name, ms) { const t = { name, ms, __timer: true }; timers.push(t); return t; },
    run() {
        while (!stopped && pumpQueue.length) {
            const ev = pumpQueue.shift();
            if (ev.connected !== undefined) badusbConnected = ev.connected;
            if (ev.type === "tick") {
                stateObj.countdown = (ev.countdown !== undefined) ? ev.countdown : stateObj.countdown;
                const { cb, ctx } = eventLoop._ctx.timer;
                cb({}, {} /*timer event*/, ...ctx);
                tickCount++;
            } else if (ev.type === "chosen") {
                const { cb, ctx } = eventLoop._ctx.chosen;
                cb({}, ev.index, ...ctx);
                reinitCountdowns.push(stateObj.countdown); // capture the re-init
            } else if (ev.type === "nav") {
                const { cb, ctx } = eventLoop._ctx.nav;
                cb({}, null /*nav event*/, ...ctx);
            } else {
                throw new Error("bad pump event " + JSON.stringify(ev));
            }
        }
    },
    stop() { stopped = true; },
};

const gui = {
    viewDispatcher: {
        currentView: null,
        switchTo(v) { currentView = v; this.currentView = v; },
        navigation: { __nav: true },
    },
};

const sandbox = {
    require(name) {
        if (name === "badusb") return badusb;
        if (name === "event_loop") return eventLoop;
        if (name === "gui") return gui;
        if (name === "gui/submenu") return { makeWith: makeWith };
        if (name === "math") return Math;
        throw new Error("unexpected require: " + name);
    },
    print(s) { printLog.push(String(s)); },
    console,
};

// ---- Scripted event sequence ----------------------------------------------
// Step / delay values at each point:
//   start  step 10 -> floor 37,   coeff 30
//   50    step 50 -> floor ~6.93e7, coeff ~2.43e7
//   0     step 0  -> floor 1,     coeff 1
// Each "chosen" commit must re-init the countdown to a fresh randomized delay
// (floor + random*[0,coeff)) WITHOUT sending a key. The tick immediately after
// the step-50 commit runs with that large re-init countdown (no press), proving
// the old short countdown no longer continues.
pumpQueue = [
    { type: "tick", countdown: 1 },            // step10 press -> "Sent 'f', next in [37..66]s" (press #1)
    { type: "chosen", index: 50 },             // re-init countdown to [floor50, floor50+coeff50) -> "Step 50: …"
    { type: "tick" },                          // re-init countdown (large) -1 -> "Sent 'f', next in <X>y" (NO press)
    { type: "tick", countdown: 1, connected: false }, // error -> "ERROR: BadUSB offline"
    { type: "chosen", index: 0, connected: true },    // re-init countdown to 1 -> "Step 0: 1s +0.5s"
    { type: "tick", countdown: 1 },            // step0 press -> "Sent 'f', next in 1s" (press #2)
    { type: "nav" },                           // back button -> stop
];

vm.runInNewContext(scriptSrc, sandbox, { filename: "pressf_dynamic.js" });

// run() has returned; the script is finished.

// ---- 1. Startup side effects ------------------------------------------------
assert.strictEqual(calls.setup, 1, "badusb.setup() must run once at startup");
assert.strictEqual(calls.quit, 1, "badusb.quit() must run exactly once after the loop stops");
assert.strictEqual(currentView && currentView.__kind, "submenu", "the shown view must be the submenu");
const rows = currentView.rows;
assert.strictEqual(rows.length, 51, "submenu must have 51 rows (steps 0..50)");
assert.strictEqual(timers.length, 1, "exactly one timer created");
assert.strictEqual(timers[0].ms, 1000, "timer period must be 1000ms");
assert.ok(eventLoop._ctx.chosen, "chosen handler must be subscribed");
assert.ok(eventLoop._ctx.nav, "navigation handler must be subscribed");
assert.ok(eventLoop._ctx.timer, "timer handler must be subscribed");

// ---- 2. Row labels: "NN, floor, +avg", step zero-padded, coarse units -------
assert.strictEqual(rows[0], "00, 1s, +0.5s", "row 0 must be '00, 1s, +0.5s' -> " + rows[0]);
assert.strictEqual(rows[10], "10, 37s, +15s", "row 10 must be '10, 37s, +15s' -> " + rows[10]);
assert.strictEqual(rows[20], "20, 1369s, +450s", "row 20 must be '20, 1369s, +450s' -> " + rows[20]);
assert.strictEqual(rows[30], "30, 14.1h, +3.7h", "row 30 must be '30, 14.1h, +3.7h' -> " + rows[30]);
assert.strictEqual(rows[50], "50, 2.2y, +140.6d", "row 50 must be '50, 2.2y, +140.6d' -> " + rows[50]);
// Zero-padded step index: every single-digit step (0..9) is rendered "0N".
{
    const pad = (n) => (n < 10 ? "0" + n : "" + n);
    for (let n = 0; n <= 9; n++) {
        assert.ok(rows[n].startsWith(pad(n) + ", "),
            "row " + n + " must start with zero-padded '" + pad(n) + ", ' -> " + rows[n]);
        assert.strictEqual(rows[n].split(",")[0], pad(n),
            "row " + n + " step field must be '" + pad(n) + "'");
    }
    // Two-digit steps are NOT padded (no extra leading zero).
    assert.strictEqual(rows[10].split(",")[0], "10", "row 10 step field is '10' (unpadded)");
    assert.strictEqual(rows[50].split(",")[0], "50", "row 50 step field is '50' (unpadded)");
}

// ---- 3. Header is a message channel, updated every tick --------------------
assert.strictEqual(initialHeader, "First keypress...",
    "initial header must be 'First keypress...' -> " + initialHeader);
// Sequence: tick@10 press (Sent), commit 50 (Step) + re-init, re-init tick
//           (Sent …y, no press), error tick (ERROR), commit 0 (Step) + re-init,
//           tick@0 press (Sent 1s).  = 6 header messages.
assert.strictEqual(headerUpdates.length, 6, "expected 6 header messages, got " + headerUpdates.length);
// tick@step10 press -> "Sent 'f', next in <37..66>s"
assert.ok(/^Sent 'f', next in \d+s$/.test(headerUpdates[0]),
    "header 1 must be a 'Sent 'f', next in Ns' message -> " + headerUpdates[0]);
// commit step 50 -> "Step 50: 2.2y +140.6d"
assert.strictEqual(headerUpdates[1], "Step 50: 2.2y +140.6d",
    "header 2 must announce the committed step -> " + headerUpdates[1]);
// PER-TICK: the tick after the commit runs with the fresh re-init countdown
// (a large step-50 value) and shows the live countdown WITHOUT pressing.
assert.ok(/^Sent 'f', next in \d+(\.\d)?y$/.test(headerUpdates[2]),
    "header 3 (re-init tick) must be a coarse-unit 'Sent 'f', next in …y' message -> " + headerUpdates[2]);
// disconnected tick -> error message
assert.strictEqual(headerUpdates[3], "ERROR: BadUSB offline",
    "header 4 must be the BadUSB error message -> " + headerUpdates[3]);
// commit step 0 -> "Step 0: 1s +0.5s"
assert.strictEqual(headerUpdates[4], "Step 0: 1s +0.5s",
    "header 5 must announce step 0 -> " + headerUpdates[4]);
// tick@step0 press -> "Sent 'f', next in 1s"
assert.strictEqual(headerUpdates[5], "Sent 'f', next in 1s",
    "header 6 must be the step-0 'Sent 'f'' message -> " + headerUpdates[5]);
// The header must never just duplicate a row label.
assert.ok(!rows.includes(currentView.header), "header must not duplicate a row label");

// ---- 4. Delay values after the run ------------------------------------------
// Final active step is 0 (last committed), so the timer is on (1, 1).
assert.strictEqual(stateObj.delayStep, 0, "final delayStep must be 0");
assert.ok(Math.abs(stateObj.delayFloor - 1.0) < 1e-9, "floor at step 0 must be 1");
assert.ok(Math.abs(stateObj.randomExtraDelayCoefficient - 1.0) < 1e-9, "coeff at step 0 must be 1");

// ---- 5. Press behaviour ------------------------------------------------------
// Presses happen on connected ticks only: tick@step10, tick@step0. The
// re-init tick (large step-50 countdown) and the disconnected tick do NOT
// press, and the commits themselves do NOT press. Total = 2.
assert.strictEqual(calls.presses.length, 2, "must press on connected ticks only, got " + calls.presses.length);
assert.ok(calls.presses.every((c) => c === 0x09), "every press must be the F key 0x09");

// ---- 5b. Center commit re-inits the countdown (no keypress) ------------------
// Each "chosen" commit must reset the countdown to a FRESH randomized delay in
// [floor, floor+coeff) -- NOT leave the old (short) countdown running.
assert.strictEqual(reinitCountdowns.length, 2, "expected 2 commits to re-init the countdown");
// Commit step 50 -> countdown in [floor50, floor50+coeff50)
{
    const f50 = Math.pow(FLOOR_BASE, 50), c50 = Math.pow(RAND_BASE, 50);
    const cd50 = reinitCountdowns[0];
    assert.ok(cd50 >= Math.floor(f50) && cd50 <= Math.floor(f50 + c50),
        "step-50 re-init countdown " + cd50 + " must be in [floor, floor+coeff) = [" +
        Math.floor(f50) + ", " + Math.floor(f50 + c50) + "]");
    assert.ok(cd50 > 1000, "step-50 re-init must be a large fresh delay, not the old short countdown");
}
// Commit step 0 -> countdown in [1, 1+1) = [1, 1]  => exactly 1
assert.strictEqual(reinitCountdowns[1], 1, "step-0 re-init countdown must be exactly 1 (floor=1, coeff=1), got " + reinitCountdowns[1]);
// And the commits must NOT have sent a key: press count is unchanged by them.
assert.strictEqual(calls.presses.length, 2, "commits must not send keypresses (total presses still 2)");

// ---- 6. Back navigation stopped the loop ------------------------------------
assert.strictEqual(stopped, true, "navigation must stop the event loop");

// ---- 7. Independent math verification of the curves -------------------------
// (FLOOR_BASE / RAND_BASE are hoisted to the top of this file.)
// Default step 10 -> (37, 30)
assert.ok(Math.abs(Math.pow(FLOOR_BASE, 10) - 37.0) < 0.001, "floor(10) ~37, got " + Math.pow(FLOOR_BASE, 10));
assert.ok(Math.abs(Math.pow(RAND_BASE, 10) - 30.0) < 0.001, "coeff(10) ~30, got " + Math.pow(RAND_BASE, 10));
// Step 0 -> (1, 1)
assert.strictEqual(Math.pow(FLOOR_BASE, 0), 1, "floor(0) must be 1");
assert.strictEqual(Math.pow(RAND_BASE, 0), 1, "coeff(0) must be 1");
// Step 11 sanity: floor ~53.1, coeff ~42.2, avg ~21.1
assert.ok(Math.abs(Math.pow(FLOOR_BASE, 11) - 53.0911) < 1e-2, "floor(11) ~53.1");
assert.ok(Math.abs(Math.pow(RAND_BASE, 11) - 42.1535) < 1e-2, "coeff(11) ~42.2");
// Step 50 is large but finite
assert.ok(Math.pow(FLOOR_BASE, 50) < 1e9, "floor(50) must be < 1e9");
assert.ok(Math.pow(RAND_BASE, 50) < 1e9, "coeff(50) must be < 1e9");
// Default countdown bounds: [37, 66]
assert.ok(Math.floor(37 + 0.999999 * 30) <= 66, "default max countdown <= 66");
assert.ok(Math.floor(37 + 0) >= 37, "default min countdown >= 37");

// ---- 8. Coarse duration formatting ------------------------------------------
// Mirror of formatDuration (s<3600, h<86400, d<31557600, y above) to pin the
// unit boundaries used by the rows and header. PER_YEAR = 365.25 * PER_DAY.
function oneDecimal(v) {
    const t = Math.floor(v * 10 + 0.5);
    const w = Math.floor(t / 10), f = t % 10;
    return f === 0 ? String(w) : w + "." + f;
}
function dur(s) {
    if (s < 3600) return oneDecimal(s) + "s";
    if (s < 86400) return oneDecimal(s / 3600) + "h";
    if (s < 31557600) return oneDecimal(s / 86400) + "d";
    return oneDecimal(s / 31557600) + "y";
}
assert.strictEqual(dur(37), "37s", "dur(37)");
assert.strictEqual(dur(3599), "3599s", "dur(3599) stays seconds");
assert.strictEqual(dur(3600), "1h", "dur(3600) rolls to hours");
assert.strictEqual(dur(5760), "1.6h", "dur(5760)");
assert.strictEqual(dur(86400), "1d", "dur(86400) rolls to days");
assert.strictEqual(dur(90000), "1d", "dur(90000) rounds to 1d");
assert.strictEqual(dur(31536000), "365d", "dur(31536000) stays days (365d < 365.25d)");
assert.strictEqual(dur(31557600), "1y", "dur(1y)");
assert.strictEqual(dur(93643932), "3y", "dur(93643932)");
// Row-label coherence for the coarse-unit rows we asserted above.
// Step field is zero-padded (30/50 already two digits).
const padStep = (n) => (n < 10 ? "0" + n : "" + n);
assert.strictEqual(padStep(30) + ", " + dur(Math.pow(FLOOR_BASE, 30)) + ", +" + dur(Math.pow(RAND_BASE, 30) / 2), rows[30]);
assert.strictEqual(padStep(50) + ", " + dur(Math.pow(FLOOR_BASE, 50)) + ", +" + dur(Math.pow(RAND_BASE, 50) / 2), rows[50]);

console.log("row 0  :", rows[0]);
console.log("row 10 :", rows[10]);
console.log("row 20 :", rows[20]);
console.log("row 30 :", rows[30]);
console.log("row 50 :", rows[50]);
console.log("initial header   :", initialHeader);
console.log("header messages  :", headerUpdates);

console.log("\nALL HARNESS CHECKS PASSED (" +
    calls.presses.length + " presses, " + headerUpdates.length + " header messages)");
console.log("print log:");
printLog.forEach((l) => console.log("  " + l));
