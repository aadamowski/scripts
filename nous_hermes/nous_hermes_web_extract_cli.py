#!/bin/sh

# Polyglot script trampoline (initially executes as Bourne shell script, then
# pivots to being a Python script through exec). Needed to express more complex
# logic of choosing the right Python interpreter than a /usr/bin/env shebang.

'''': # This starts a multi-line string in Python, but is a no-op command in shell
exec "$HOME/.local/share/pipx/venvs/hermes-agent/bin/python" -E "$0" "$@"
'''

"""Call hermes-agent's ``web_extract`` tool for the given URL(s) and print the result.

Useful for checking whether the tool works properly in a
well-configured Hermes harness, without having to go through
the unpredictable LLM.

Usage:
    web_extract_cli.py <url> [more urls ...]

The URLs are sys.argv[1:]. web_extract accepts a list of URLs (capped at 5),
so every argument is collected into the ``urls`` list. The dispatch result is
printed as-is.
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
        print("usage: web_extract_cli.py <url> [more urls ...]", file=sys.stderr)
        return 2

    urls = sys.argv[1:]
    result = registry.dispatch("web_extract", {"urls": urls})
    print(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
