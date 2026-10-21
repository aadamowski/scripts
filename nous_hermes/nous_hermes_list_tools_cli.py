#!/bin/sh

# Polyglot script trampoline (initially executes as Bourne shell script, then
# pivots to being a Python script through exec). Needed to express more complex
# logic of choosing the right Python interpreter than a /usr/bin/env shebang.

'''': # This starts a multi-line string in Python, but is a no-op command in shell
exec "$HOME/.local/share/pipx/venvs/hermes-agent/bin/python" -E "$0" "$@"
'''

"""List every tool registered in the hermes-agent tool registry.

Prints the tool names one per line, sorted alphabetically, as a flat list
(no grouping by toolset).

Usage:
    list_tools_cli.py

No arguments.
"""

import sys

from tools.registry import registry, discover_builtin_tools

# Load all built-in tool modules so each one's module-level registry.register()
# call runs and populates the registry. Without this, the registry would be
# empty (tools.registry alone only defines the singleton). discover_builtin_tools
# imports every tools/*.py module that self-registers and tolerates per-module
# import failures (e.g. optional deps not installed).
discover_builtin_tools()


def main() -> int:
    names = registry.get_all_tool_names()
    for name in names:
        print(name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
