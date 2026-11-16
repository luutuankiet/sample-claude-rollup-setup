#!/bin/bash
# SessionStart hook: put the rollup rules into the agent's context.
#
# Fires on startup, resume, /clear and after a compaction, so the rules are
# back in context every time the conversation is rebuilt. Plain stdout from a
# SessionStart hook is added to the model's context; no JSON needed.
#
# Never blocks a session: every error path exits 0 with no output.

set -euo pipefail
trap 'exit 0' ERR

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd) || exit 0
rule="$dir/../rules/rollup.md"
[ -r "$rule" ] || exit 0

cat "$rule" 2>/dev/null || true
exit 0
