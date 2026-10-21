#!/bin/sh

# Polyglot script trampoline (initially executes as Bourne shell script, then
# pivots to being a Python script through exec). Needed to express more complex
# logic of choosing the right Python interpreter than a /usr/bin/env shebang.

'''': # This starts a multi-line string in Python, but is a no-op command in shell
exec "$HOME/.local/share/pipx/venvs/hermes-agent/bin/python" -E "$0" "$@"
'''

"""Run the hermes-agent ``session_search`` tool against the local session DB.

Usage:
    session_search_cli.py <search string>

The search string is sys.argv[1]. It is dispatched through the tool registry
exactly the way the agent would call it: registry.dispatch("session_search",
{"query": <arg>}).
"""

import json
import sys

from tools.registry import registry

# Importing the tool module executes its module-level registry.register()
# call. tools.registry alone only defines the (empty) registry singleton, so
# without this import the "session_search" entry would not exist.
import tools.session_search_tool  # noqa: F401  (side effect: registers tool)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: session_search_cli.py <search string>", file=sys.stderr)
        return 2

    query = sys.argv[1]
    result = registry.dispatch("session_search", {"query": query})

    # dispatch() returns a JSON string for normal tools, or a dict for the
    # multimodal envelope. Normalise both to printable JSON.
    if isinstance(result, (str, int, float, bool)) or result is None:
        text = result if isinstance(result, str) else json.dumps(result)
    else:
        text = json.dumps(result, ensure_ascii=False, indent=2)
    print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
