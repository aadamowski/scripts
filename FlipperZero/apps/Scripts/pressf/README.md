# pressf

Press F to pay respects:

BadUSB F-key spammers for the Flipper Zero (Momentum firmware). Two scripts:

## pressf.js

The simpler variant: a **fixed** delay of 37 s floor plus a random
extra in [0, 30) — a keypress every 37–66 s. Shows a dialog with a live
countdown ("Countdown: Ns", "Sent 'f'. Next: Ns") and a **Stop** button; the
left/STOP button or the physical Back button both terminate the script. If the
BadUSB is not connected it shows an error and retries in 1 s.

## pressf_dynamic.js

Spams the `F` keypress at randomized intervals with a **selectable** delay.
The delay is a floor plus a random extra, both derived from gentle exponential
curves over 51 selectable "steps" (step 10 is the default: 37 s floor, ~30 s
random range; step 0: 1 s / 1 s; capped at step 50). A submenu lists all steps
as `NN, floor, +random avg` rows (step zero-padded to two digits, durations in
coarse units s/h/d/y): the physical Up/Down buttons move the cursor, Center
commits the chosen step, and the Back button stops the script. The submenu
header is a message channel to the user (startup, live countdown, commit,
BadUSB-offline error).

## Running tests

The tests are plain Node.js scripts that use only core modules (no
dependencies to install). Node.js is available in the Ubuntu archives:

    sudo apt update
    sudo apt install nodejs

Each mock harness executes its script against mocks of the Momentum runtime
(`badusb`, `event_loop`, `gui`, and the view module it uses), so it runs on a
workstation without any Flipper hardware attached. On success a harness exits
0 and prints `ALL HARNESS CHECKS PASSED`; a failed assertion prints a message
and exits non-zero.

    node test/pressf.test.js           # pressf.js
    node test/pressf_dynamic.test.js   # pressf_dynamic.js

A syntax check is also available:

    node --check pressf.js
    node --check pressf_dynamic.js
