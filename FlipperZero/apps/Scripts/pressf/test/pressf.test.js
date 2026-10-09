#!/usr/bin/env node
/*
 * Momentum mock test harness for pressf.js (the original fixed-delay variant)
 *
 * Executes the REAL pressf.js against faithful mocks of the Momentum (mJS)
 * runtime and asserts the delay model + control flow:
 *   - fixed delay: 37 s floor + a random extra in [0, 30) -> countdown in [37, 66]
 *   - the dialog text is a live message channel:
 *     "Countdown: Ns", "Sent 'f'. Next: Ns", "ERROR: BadUSB Not connected"
 *   - presses the F key (0x09) on connected ticks only
 *   - a disconnected BadUSB shows the error text and retries in 1 s (no press)
 *   - the dialog's STOP button AND the back navigation button both stop the
 *     loop and run badusb.quit()
 *
 * Run: node test/pressf.test.js
 *
 * pressf.js uses a dialog (not a submenu) and has two independent stop paths:
 * the physical STOP button fires the dialog's "input" contract with value
 * "left", while the physical back key fires the view dispatcher's "navigation"
 * contract. This harness models both.
 */
const vm = require("vm");
const fs = require("fs");
const path = require("path");
const assert = require("assert");

const scriptSrc = fs.readFileSync(path.join(__dirname, "..", "pressf.js"), "utf8");

// ---- One isolated mock environment per run --------------------------------
// Fresh mock modules + event queue per run so the two stop paths (STOP button,
// back key) can be exercised independently. Returns the recorded side effects.
function makeRun(pump, initialConnected) {
    const calls = { setup: 0, quit: 0, presses: [] };
    const printLog = [];
    const subscribed = [];   // contract kinds the script subscribed to
    let stopped = false;
    let currentView = null;
    const timers = [];
    const textUpdates = [];  // every .set("text", ...) the script performs
    let initialHeader = null;
    let initialText = null;
    let stateObj = null;
    let badusbConnected = initialConnected;

    // Dialog view: makeWith({header, text, left}) -> view with an "input"
    // contract (button name) and a mutable "text" prop.
    function makeView(props) {
        initialHeader = props ? props.header : "";
        initialText = props ? props.text : "";
        return {
            __kind: "dialog",
            header: initialHeader,
            text: initialText,
            left: props ? props.left : "",
            input: { __contract: true },
            set(name, value) {
                if (name === "text") { this.text = value; textUpdates.push(value); }
            },
        };
    }

    const badusb = {
        setup() { calls.setup++; },
        quit() { calls.quit++; },
        isConnected() { return badusbConnected; },
        press(c) { calls.presses.push(c); },
    };

    // mJS calling convention: handler(subscription, EVENT_VALUE, ...contextArgs)
    const eventLoop = {
        _ctx: {},
        subscribe(contract, cb, ...ctx) {
            if (contract && contract.__timer) { eventLoop._ctx.timer = { cb, ctx }; stateObj = ctx[0]; subscribed.push("timer"); return; }
            if (contract && contract.__nav) { eventLoop._ctx.nav = { cb, ctx }; subscribed.push("navigation"); return; }
            if (contract && contract.__contract) { eventLoop._ctx.input = { cb, ctx }; subscribed.push("input"); return; }
            throw new Error("unrecognized contract in subscribe");
        },
        timer(name, ms) { const t = { name, ms, __timer: true }; timers.push(t); return t; },
        run() {
            while (!stopped && pump.length) {
                const ev = pump.shift();
                if (ev.connected !== undefined) badusbConnected = ev.connected;
                if (ev.type === "tick") {
                    if (ev.countdown !== undefined) stateObj.countdown = ev.countdown;
                    const { cb, ctx } = eventLoop._ctx.timer;
                    cb({}, {} /*timer event*/, ...ctx);
                } else if (ev.type === "left") {
                    const { cb, ctx } = eventLoop._ctx.input;
                    cb({}, "left" /*button event*/, ...ctx);
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
            if (name === "gui/dialog") return { makeWith: makeView };
            if (name === "math") return Math;
            throw new Error("unexpected require: " + name);
        },
        print(s) { printLog.push(String(s)); },
        console,
    };

    vm.runInNewContext(scriptSrc, sandbox, { filename: "pressf.js" });

    return {
        calls, printLog, subscribed, stopped, currentView, timers,
        textUpdates, initialHeader, initialText, stateObj,
    };
}

// ---- Test 1: fixed delay + STOP button stops the loop ----------------------
{
    const r = makeRun([
        { type: "tick", countdown: 1 }, // 1 -> 0 -> press, re-arm in [37, 66]
        { type: "tick" },               // [37,66] -> [36,65] -> "Countdown: Ns"
        { type: "left" },               // STOP button -> stop
    ], true);

    // Startup side effects.
    assert.strictEqual(r.calls.setup, 1, "badusb.setup() must run once at startup");
    assert.strictEqual(r.calls.quit, 1, "badusb.quit() must run exactly once after the loop stops");
    assert.strictEqual(r.currentView && r.currentView.__kind, "dialog", "the shown view must be the dialog");
    assert.strictEqual(r.currentView.header, "F-key Spam Control", "dialog header");
    assert.strictEqual(r.currentView.left, "Stop", "dialog left button label is 'Stop'");
    assert.strictEqual(r.initialHeader, "F-key Spam Control", "initial dialog header captured at creation");
    assert.strictEqual(r.initialText, "First keypress...\nPress STOP to terminate", "initial dialog text");
    assert.strictEqual(r.timers.length, 1, "exactly one timer created");
    assert.strictEqual(r.timers[0].ms, 1000, "timer period must be 1000ms");
    assert.deepStrictEqual(r.subscribed.slice().sort(), ["input", "navigation", "timer"],
        "input, navigation and timer contracts must all be subscribed");

    // Press behaviour: the connected tick presses the F key once; the next tick does not.
    assert.strictEqual(r.calls.presses.length, 1, "must press exactly once (first tick), got " + r.calls.presses.length);
    assert.strictEqual(r.calls.presses[0], 0x09, "the press must be the F key 0x09");

    // Fixed delay: after the press the countdown re-arms in [37, 66].
    assert.ok(r.stateObj.countdown >= 37 && r.stateObj.countdown <= 66,
        "post-press countdown must be in [37, 66] (37 + floor(random*30)), got " + r.stateObj.countdown);

    // Dialog text is a live message channel: press message then countdown.
    assert.strictEqual(r.textUpdates.length, 2, "expected 2 live text updates, got " + r.textUpdates.length);
    assert.ok(r.textUpdates[0].startsWith("Sent 'f'. Next: ") && r.textUpdates[0].endsWith("s\nPress STOP"),
        "first text must be the press message -> " + JSON.stringify(r.textUpdates[0]));
    assert.ok(r.textUpdates[1].startsWith("Countdown: ") && r.textUpdates[1].endsWith("s\nPress STOP"),
        "second text must be the countdown -> " + JSON.stringify(r.textUpdates[1]));

    // STOP button stopped the loop.
    assert.strictEqual(r.stopped, true, "STOP button must stop the event loop");
    assert.ok(r.printLog.includes("Script stopped by user."), "must log the user-stop message");

    console.log("Test 1 (fixed delay + STOP button) passed");
    console.log("  post-press countdown: " + r.stateObj.countdown + " s (in [37, 66])");
    console.log("  dialog texts: " + JSON.stringify(r.textUpdates));
}

// ---- Test 2: disconnected BadUSB shows error; back navigation stops --------
{
    const r = makeRun([
        { type: "tick", countdown: 1, connected: false }, // error, retry in 1s, NO press
        { type: "tick", countdown: 1, connected: true },  // back online -> press, re-arm in [37,66]
        { type: "nav" },                                  // back key -> stop
    ], true);

    // Only the reconnected tick presses, with the F key.
    assert.strictEqual(r.calls.presses.length, 1, "only the reconnected tick presses, got " + r.calls.presses.length);
    assert.strictEqual(r.calls.presses[0], 0x09, "the press must be the F key 0x09");

    // The disconnected tick shows the error text first.
    assert.strictEqual(r.textUpdates[0], "ERROR: BadUSB\nNot connected\n\nPress STOP",
        "first text must be the BadUSB error text -> " + JSON.stringify(r.textUpdates[0]));
    assert.ok(r.textUpdates[1].startsWith("Sent 'f'. Next: "),
        "second text must be the press message -> " + JSON.stringify(r.textUpdates[1]));

    // After the reconnected press the countdown re-arms in [37, 66].
    assert.ok(r.stateObj.countdown >= 37 && r.stateObj.countdown <= 66,
        "post-press countdown must be in [37, 66], got " + r.stateObj.countdown);

    // Back navigation stopped the loop (STOP button not involved).
    assert.strictEqual(r.stopped, true, "back navigation must stop the event loop");
    assert.ok(r.printLog.includes("Script stopped by back navigation button."), "must log the back-nav stop message");

    console.log("Test 2 (BadUSB error + back navigation) passed");
    console.log("  error text: " + JSON.stringify(r.textUpdates[0]));
    console.log("  post-press countdown: " + r.stateObj.countdown + " s (in [37, 66])");
}

console.log("\nALL HARNESS CHECKS PASSED (pressf.js)");
