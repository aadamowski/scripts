/*
 * == Press F to pay respects ==
 *
 * BadUSB F-key spam - sends "f" keypress with countdown timer
 * Shows dialog with "Stop" button to terminate the event loop
 */

let badusb = require("badusb");
let eventLoop = require("event_loop");
let gui = require("gui");
let dialog = require("gui/dialog");
let math = require("math");

// Initialize BadUSB
badusb.setup();

// State variables
let state = {
    countdown: 0,
    running: true,
    dialogView: null
};

// Create dialog view
state.dialogView = dialog.makeWith({
    header: "F-key Spam Control",
    text: "First keypress...\nPress STOP to terminate",
    left: "Stop"
});

// Show the dialog
gui.viewDispatcher.switchTo(state.dialogView);

// Handle button press - subscribe to input event on dialog
eventLoop.subscribe(state.dialogView.input, function(subscription, button, evLoop, gui) {
    if (button === "left") {
        state.running = false;
        evLoop.stop();
        print("Script stopped by user.");
    }
}, eventLoop, gui);

// Handle the back navigation button - this is a DIFFERENT API than the dialog
// button handling above. The physical back key does NOT fire the dialog's
// "input" contract; it fires the view dispatcher's "navigation" contract, so
// it must be subscribed to separately.
eventLoop.subscribe(gui.viewDispatcher.navigation, function(subscription, _item, evLoop) {
    state.running = false;
    evLoop.stop();
    print("Script stopped by back navigation button.");
}, eventLoop);

// Timer callback for countdown
function onTimer(subscription, _item, timerState) {
    if (!timerState.running) return;

    timerState.countdown--;

    if (timerState.countdown <= 0) {
        // Check USB connection before sending key
        if (badusb && badusb.isConnected() && badusb.press) {
            badusb.press(0x09);
            print("Sent 'f' keypress");

            timerState.countdown = 37 + math.floor(math.random() * 30);
            print("Next press in " + timerState.countdown.toString() + " seconds");

            // Update dialog
            timerState.dialogView.set("text", "Sent 'f'. Next: " + timerState.countdown.toString() + "s\nPress STOP");
        } else {
            // Show error but keep retrying
            print("BadUSB not connected - cannot send keys");
            timerState.dialogView.set("text", "ERROR: BadUSB\nNot connected\n\nPress STOP");
            // Reset countdown to retry in 1 second
            timerState.countdown = 1;
        }
    } else {
        // Update countdown display
        timerState.dialogView.set("text", "Countdown: " + timerState.countdown.toString() + "s\nPress STOP");
        print("Countdown: " + timerState.countdown.toString() + "s");
    }
    
    // Return updated state for event loop
    return [timerState];
}

// Subscribe to periodic timer every 1000ms
// Initial countdown = 0 for immediate first keypress
eventLoop.subscribe(eventLoop.timer("periodic", 1000), onTimer, state);

// Run event loop
print("F-key spam started. Press STOP to terminate.");
eventLoop.run();

// Cleanup
print("Script stopped.");
badusb.quit();
