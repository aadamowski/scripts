#!/bin/sh

# Polyglot script trampoline (initially executes as Bourne shell script, then
# pivots to being a Python script through exec). Needed to express more complex
# logic of choosing the right Python interpreter than a /usr/bin/env shebang.

'''': # This starts a multi-line string in Python, but is a no-op command in shell
exec "$HOME/.local/share/pipx/venvs/hermes-agent/bin/python" -E "$0" "$@"
'''

"""Call hermes-agent's ``web_search`` tool for the given search term and print the result.

Useful for checking whether the tool works properly in a
well-configured Hermes harness, without having to go through
the unpredictable LLM.

Usage:
    web_search_cli.py <search term>

The search term is sys.argv[1]. An optional second argument overrides the
result count (default 5). The dispatch result is printed as-is.
"""

import sys

from tools.registry import registry

# Importing the tool module executes its module-level registry.register()
# calls for web_search and web_extract. tools.registry alone only defines the
# (empty) registry singleton, so without this import those entries would not
# exist.
import tools.web_tools  # noqa: F401  (side effect: registers web tools)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: web_search_cli.py <search term> [limit]", file=sys.stderr)
        return 2

    query = sys.argv[1]
    limit = 5
    if len(sys.argv) >= 3:
        try:
            limit = int(sys.argv[2])
        except ValueError:
            print(f"warning: bad limit {sys.argv[2]!r}, using 5", file=sys.stderr)

    result = registry.dispatch("web_search", {"query": query, "limit": limit})
    print(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
