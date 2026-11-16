# sample-claude-rollup-setup

A Claude Code setup that makes the agent fold a busy session into one final
reply, the rollup, for a user who reads only the last reply. Bash and markdown;
no build, no runtime.

## The idea in five lines

1. The user's attention is the scarce resource. They read only the last reply.
2. While work runs, replies are 1-2 lines. Findings wait.
3. When nothing runs, the last reply is a rollup: verdict first, everything a
   cold reader needs, every open question restated in full.
4. `hooks/load-rule.sh` (SessionStart) loads `rules/rollup.md` at every start,
   resume, `/clear` and compaction, so the rule never falls out of context.
5. `hooks/rollup-nudge.sh` (UserPromptSubmit) prints `hooks/rollup-nudge.txt`
   only when the payload holds `<task-notification>`: a background result just
   landed, the moment agents most often forget the rule.

Full map and diagrams: `docs/how-it-works.md`.

## Installing it for a user

Ask the user which option they want, recommending A. Never install two: a
plugin hook merges with a settings hook of the same event, so mixing them fires
every hook twice with no error.

| option | do | best when |
|---|---|---|
| A. plugin | `claude plugin marketplace add luutuankiet/sample-claude-rollup-setup`, then `claude plugin install rollup@sample-claude-rollup-setup` | the user wants it everywhere and updatable |
| B. manual hooks | clone to `~/.claude/rollup-setup`, merge the two hook entries from README option B into `~/.claude/settings.json` or `<project>/.claude/settings.json` | no plugins allowed, or one project only |
| C. rule in memory | clone as in B, add `@~/.claude/rollup-setup/rules/rollup.md` to a `CLAUDE.md`, bind only the `UserPromptSubmit` hook | the user wants to read and edit the rule |

Steps:

1. Check for an existing install first: `claude plugin list`, and grep the
   target `settings.json` for `rollup-nudge.sh`. If one exists, stop and ask.
2. Read the target `settings.json` before editing. Merge into an existing
   `hooks` object; never replace the file or other hooks.
3. Verify without a new session: pipe a fake payload through the nudge.

   ```sh
   echo '{"prompt":"<task-notification>x</task-notification>"}' | bash hooks/rollup-nudge.sh
   echo '{"prompt":"hello"}' | bash hooks/rollup-nudge.sh
   ```

   The first prints `ROLLUP CHECK ...`; the second prints nothing.
4. Tell the user to start a new session and run `/hooks` to see both entries.

## Changing it

- The rule is `rules/rollup.md`. The nudge is a short reminder of it; when
  the rule changes shape, check the nudge still names the right shortcuts.
- Keep the nudge short. It is printed on every background result.
- Both scripts must exit 0 on every error path. A hook that fails can block the
  user's prompt.
- Write bash for 3.2 (macOS default) under `set -euo pipefail`: no `timeout`,
  no GNU-only flags, no `jq`.
- Hook stdout becomes model context as plain text; do not wrap it in JSON.
- The demo screenshot lives on the `assets` branch; `main` links its raw URL.
