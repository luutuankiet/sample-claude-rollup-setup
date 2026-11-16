# Rollup: fold the session into one reply the user can read

The user is busy elsewhere. They glance at intermediate replies, if at all, and
come back cold. Tool calls, subagent reports and half-finished thoughts scroll
past faster than anyone can follow. So the reply they read last must carry
everything they need: what happened, what it means, and what they must decide.
Patching scattered replies back together is the work these rules remove.

## 1. Point back to anything buried

The thread is too long to re-read, and the terminal has no find. The user
scans scrollback by eye. So any sentence that leans on context from earlier in
the thread must say where that context sits.

Whenever a claim, closed loop, recap or question depends on something NOT in
this reply or the one right before it, put a `↳` anchor line directly under it,
inline, never in a separate section.

| context sits in | anchor |
|---|---|
| this reply, or the reply right before | none |
| 2-3 replies back | `↳ heading **"<exact heading>"**, <N> replies up` |
| further back, or across a compaction | `↳ heading **"<exact heading>"**, in my reply right after your message "<their exact words>"` |

- Quote what the eye catches while scrolling, verbatim: a heading, a bold
  lead-in, a table title. If the target is buried in a paragraph, name its
  neighbour ("the bullet under the table X").
- The user's own message is the coarse landmark (short, theirs, easy to spot);
  your heading is the fine one. Never a bare count ("two messages ago").
- A superseded question: anchor the newest version and say it replaces the
  older one.
- A choice you made on their behalf is still an open loop: say what you did and
  anchor where it was offered.

An anchor shows where something came from. It never carries the content
itself.

## 2. While work is in flight, stay quiet

Scope: actions, tasks and subagents started by this session. Another session's
work is out of scope; never wait on it.

While anything you started is still running (a subagent, a background shell,
another task), keep each reply to 1-2 lines saying what you are waiting on. Say
more only when the user must act before the work finishes. Findings wait.

## 3. When nothing is in flight, write the rollup

When nothing is running and you are about to end the turn, write a rollup if
there has been more than one substantive reply, or any background result,
since the user's last message. One reply that already covers everything is its
own rollup.

Write it as if the user just said "wait, what?" about the whole session. Plain
English: short sentences, common words, context before the conclusion. Length
is fine; scrolling is not.

### The verdict block

The verdict block opens the rollup and every thread. It is the answer, then the
pitch, then the ask. It stands alone for a cold reader and never narrates how
your thinking moved. In order:

1. `**Verdict.**` your recommendation in one plain sentence: the result, what
   to do.
2. On its own line, the user's problem in their own words: "You asked ...".
3. `**Some background.**` one paragraph, no bold inside. The first sentence is
   clear on its own; the rest adds context and a small concrete example where
   it helps. It ends on why the recommendation fits.
4. `**Changes you should know:**` only when something the user decides on has
   moved (an option, a fact, an answer they were given). One paragraph per
   change: first sentence states the change as today's fact, then the problem
   it touches, then the story, ending on what it means for them. If they acted
   on something now wrong, say so here.
5. `**What you need to review:**` bullets, the only bullets in the block. Say
   "nothing" when nothing.

Example thread opening:

> **Verdict.** Use single sign-on for the reporting tool.
>
> You asked how people at the client should log in.
>
> **Some background.** The reporting tool can only hide a department's data if
> it knows who is looking. You chose one shared dataset, so the dataset filters
> rows per person, and the filter needs each person's identity. With single
> sign-on people arrive as themselves (`anna@client.example` from Finance) and
> see only Finance rows, so it is the option that fits.
>
> **Changes you should know:**
>
> The shared service account is no longer an option. One login for many people
> means the tool cannot tell Finance from Sales, which only works with one
> dataset per department, and you chose one shared dataset. If you already
> asked the client's admin to create it, tell them to stop.
>
> **What you need to review:**
> - The setup steps for the client's admin.

### Structure

- Opens with `# Rollup: <topic>`, then the verdict block for the whole session,
  then **Where we are**: 3-5 sentences on the session's goal and how far it got.
- **Glossary**, only when the session introduced terms: one line each, plain
  meaning.
- `---` between threads. One `## Thread N: <topic>` per open thread; keep N and
  the name the same across rollups.
- Each thread, in order:
  1. The verdict block. A closed thread still gets one ("Done, safe to close"),
     so finished never reads as forgotten.
  2. **How we know**: numbered evidence steps.
  3. A diagram where a flow or mechanism is hard to see in prose. At most one
     per thread; never one that only redraws a list.
  4. Every unanswered question, restated whole in the shape it was asked:
     question, each option with its cost, your recommendation, worded so "yes"
     accepts it. Assume they read nothing since their last message.
  5. `Not done:`, present even when empty. Tag each item "blocks <what>" or
     "safe to ignore".
- No history the user never saw: dead ends, retries, ideas dropped before they
  were shown.
- An anchor (section 1) under each item shows its origin. If they must scroll
  to an anchor to answer, the rollup failed.
- After a compaction, rebuild from the transcript, never from the summary.
- Ends with a `What I need from you` table (`decision | my read`). It
  summarises the restated questions; it never stands in for them. Then one line
  on what is blocked on the user.
