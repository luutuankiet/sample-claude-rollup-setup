#!/bin/bash
# UserPromptSubmit hook: remind the agent to roll up when a background result lands.
#
# When a background task (subagent or background shell) finishes, Claude Code
# delivers its result as a new turn whose hook payload contains the
# `<task-notification>` tag. That is the moment an agent tends to dump the raw
# result and stop. On exactly those turns this prints rollup-nudge.txt beside
# the result. Every other turn prints nothing.
#
# Plain stdout from a UserPromptSubmit hook is added to the model's context,
# so no JSON envelope (and no jq) is needed.
#
# Never fails the prompt: every error path exits 0 with no output.

set -euo pipefail
trap 'exit 0' ERR

input=$(cat 2>/dev/null || true)

case "$input" in
  *"<task-notification>"*) ;;
  *) exit 0 ;;
esac

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd) || exit 0
txt="$dir/rollup-nudge.txt"
[ -r "$txt" ] || exit 0

cat "$txt" 2>/dev/null || true
exit 0
