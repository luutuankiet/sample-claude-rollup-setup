# sample-claude-rollup-setup

A small, self-contained Claude Code setup that keeps **you** on the main thread.
The agent can run as many tool calls, subagents and background jobs as it
likes; you read one reply at the end, the **rollup**, and it has everything:
the verdict first, your original ask, the evidence, every open question in
full, and what is not done.

![A busy session folded into one rollup](https://raw.githubusercontent.com/luutuankiet/sample-claude-rollup-setup/assets/demo.png)

## Why

Your attention is limited; the agent's output is not. In a long session the
intermediate steps (tool calls, file reads, subagent reports) scroll past faster
than you can follow. You still half-watch them, and when the agent stops, the
facts you need are scattered across a dozen replies. You stitch them back
together before you can decide anything, and somewhere along the way the scope
you set at the start drifts.

This setup hands the stitching to the agent:

- **While work is running**, replies stay to 1-2 lines: what it is waiting on.
- **When nothing is running**, the last reply is a rollup written for a reader
  who saw none of the session, starting with the key information.
- **When a background result lands**, a hook reminds the agent of exactly that,
  because it is the moment agents most often forget.

## What is in it

| piece | job |
|---|---|
| `rules/rollup.md` | the rule: point back to buried context, stay quiet while waiting, write the rollup |
| `hooks/load-rule.sh` | loads the rule at every session start, resume, `/clear` and compaction |
| `hooks/rollup-nudge.sh` + `.txt` | a short reminder, printed only when a background result arrives |

How they fit together, with diagrams: [docs/how-it-works.md](docs/how-it-works.md).

## Install

Pick **one** of these. Mixing two makes the hooks fire twice.

### A. As a plugin (one command, recommended)

```sh
claude plugin marketplace add luutuankiet/sample-claude-rollup-setup
claude plugin install rollup@sample-claude-rollup-setup
```

Start a new session. Both hooks are live for every project. Update later with
`claude plugin update rollup@sample-claude-rollup-setup`.

### B. Manual hooks in your settings

Clone the repo somewhere stable:

```sh
git clone https://github.com/luutuankiet/sample-claude-rollup-setup ~/.claude/rollup-setup
```

Then merge this into `~/.claude/settings.json` (all projects) or a project's
`.claude/settings.json` (that project only):

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "bash \"$HOME/.claude/rollup-setup/hooks/load-rule.sh\"", "timeout": 5 } ] }
    ],
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "bash \"$HOME/.claude/rollup-setup/hooks/rollup-nudge.sh\"", "timeout": 5 } ] }
    ]
  }
}
```

### C. Rule in `CLAUDE.md`, nudge only as a hook

If you would rather keep the rule in memory, where you can see and edit it, add
this line to `~/.claude/CLAUDE.md` (or a project's `CLAUDE.md`):

```md
@~/.claude/rollup-setup/rules/rollup.md
```

and bind only the `UserPromptSubmit` hook from option B. Claude Code reloads
`CLAUDE.md` after a compaction, so you do not need the `SessionStart` hook.

### D. Let your agent do it

Open Claude Code anywhere and say:

> Read https://github.com/luutuankiet/sample-claude-rollup-setup/blob/main/AGENTS.md and install this setup for me.

`AGENTS.md` walks the agent through choosing an option, installing it and
checking it works.

### Check it works

Run `/hooks` in a new session: you should see `SessionStart` and
`UserPromptSubmit` entries pointing at this repo's scripts. Then ask the agent
to run something in the background (for example "run `sleep 20` in the
background, then tell me when it is done"). When it finishes you should get a
reply opening with `# Rollup:` and a `**Verdict.**` line.

## Demo: what a rollup looks like

A made-up session: you asked the agent to find why the nightly export is slow,
and it sent two subagents off in the background. This is the one reply you
read when you come back.

---

> # Rollup: nightly export is slow because of one unindexed join
>
> **Verdict.** Add the index on `orders.customer_id`; it takes the export from
> 41 minutes to about 6, and nothing else needs to change.
>
> You asked why the nightly export started taking over 40 minutes last week.
>
> **Some background.** The export joins every order to its customer. Last
> Tuesday's migration rebuilt the `orders` table and dropped its index on
> `customer_id`, so each join now scans the whole table. On a copy of last
> night's data, the same export ran in 41 minutes without the index and 5
> minutes 50 seconds with it. That is why the index is the fix and not a bigger
> machine.
>
> **Changes you should know:**
>
> The bigger database instance is no longer worth it. It was my first guess and
> it is still in the draft budget request, but the test copy ran on the same
> size of machine and got fast with the index alone. If the budget request
> has gone out, the extra line can come off.
>
> **What you need to review:**
> - The one-line migration in `migrations/0042_orders_customer_idx.sql`.
>
> **Where we are.** The goal was to find and fix the slowdown. The cause is
> found and proven on a copy; the fix is written but not applied to
> production, because that needs your go-ahead.
>
> ---
>
> ## Thread 1: why the export is slow
>
> **Verdict.** Done, safe to close: the missing index is the whole cause.
>
> **How we know**
> 1. The export log shows the join step went from 3 to 38 minutes on the night
>    of the migration.
> 2. The migration file rebuilds `orders` without re-creating its indexes.
> 3. On a copy of the data, adding the index brought the export back to 5m50s.
>
> `Not done:` nothing.
>
> ---
>
> ## Thread 2: applying the fix
>
> **Verdict.** Apply the index tonight before the export runs.
>
> You asked for the fix, not just the cause.
>
> **Some background.** Building the index takes about 2 minutes and locks
> nothing, because the migration uses the database's online index build.
>
> **Should I apply the migration to production tonight at 21:00, before the
> export at 23:00?**
> - **A: tonight.** The export is fast from tonight. Cost: a 2 minute build on
>   production; if it fails, the export simply stays slow one more night.
> - **B: wait for Monday's release.** No out-of-band change. Cost: four more
>   nights of 40 minute exports, and the morning report stays late.
>
> My read: A. "Yes" applies it tonight at 21:00.
> ↳ heading **"Thread 2: applying the fix"**, in my reply right after your
> message "ok find out why and fix it"
>
> `Not done:`
> - Production migration: blocks the fast export, waiting on you.
> - The dashboards that read the export are untested with the new timing: safe
>   to ignore, they only read the finished file.
>
> ---
>
> | decision | my read |
> |---|---|
> | apply the index tonight | yes, at 21:00 |
>
> Blocked on you: the go-ahead for tonight's migration.

---

## Repo layout

```
.claude-plugin/   plugin.json + marketplace.json (option A)
hooks/            hooks.json, load-rule.sh, rollup-nudge.sh, rollup-nudge.txt
rules/rollup.md   the rule the agent follows
docs/             how-it-works.md, the component map and flows
AGENTS.md         onboarding for an agent installing or changing this setup
```

The demo screenshot lives on the `assets` branch so `main` stays small.

## License

MIT
