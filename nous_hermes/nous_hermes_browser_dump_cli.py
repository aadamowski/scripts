#!/bin/sh

# Polyglot script trampoline (initially executes as Bourne shell script, then
# pivots to being a Python script through exec). Needed to express more complex
# logic of choosing the right Python interpreter than a /usr/bin/env shebang.

'''': # This starts a multi-line string in Python, but is a no-op command in shell
exec "$HOME/.local/share/pipx/venvs/hermes-agent/bin/python" -E "$0" "$@"
'''

"""Navigate a page with hermes-agent's ``browser_navigate`` tool and dump the
full page contents via ``browser_snapshot``, both dispatched through the tool
registry exactly the way the agent would call them.

Useful for checking whether the tool works properly in a
well-configured Hermes harness, without having to go through
the unpredictable LLM.

Usage:
    browser_dump_cli.py <url>

The URL is sys.argv[1]. The script:
  1. registry.dispatch("browser_navigate", {"url": <arg>})
  2. registry.dispatch("browser_snapshot", {"full": True})   # full page contents

Both calls share the same browser session within this process (the default
task_id), so the snapshot reflects the page just navigated to.
"""

import json
import sys

from tools.registry import registry

# Importing the tool module executes its module-level registry.register()
# calls for browser_navigate and browser_snapshot. tools.registry alone only
# defines the (empty) registry singleton, so without this import those entries
# would not exist.
import tools.browser_tool  # noqa: F401  (side effect: registers browser tools)


def _print_json(label: str, result) -> None:
    """Print a tool result (JSON string or multimodal dict) as readable JSON."""
    if isinstance(result, str):
        text = result
    elif result is None:
        text = "null"
    elif isinstance(result, (int, float, bool)):
        text = json.dumps(result)
    else:
        text = json.dumps(result, ensure_ascii=False, indent=2)
    sys.stderr.write(f"===== {label} =====\n")
    print(text)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: browser_dump_cli.py <url>", file=sys.stderr)
        return 2

    url = sys.argv[1]

    nav = registry.dispatch("browser_navigate", {"url": url})
    _print_json("browser_navigate", nav)

    snap = registry.dispatch("browser_snapshot", {"full": True})
    _print_json("browser_snapshot (full)", snap)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
