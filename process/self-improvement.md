# Self-improvement loop

Every agent — and the team as a whole — gets better by **editing its own identity** when it makes
a preventable mistake. This is the "living" in *Living Artifact*.

## The principle

When you make a mistake that you could have avoided, and that you are likely to make again, you
**change yourself** so the next version of you doesn't repeat it. The fix lives in the agent
definition, not in a person's memory.

A mistake is "preventable & recurring" when a written instruction in your own definition would have
stopped it. One-off environmental hiccups don't count.

## Triggers

1. **Review feedback** — a reviewer agent or the human points out a defect you introduced.
2. **Self-insight** — you notice mid-work that you did something wrong, took a wrong turn, or found
   a sharper way to do your job.
3. **A `needs-decision` that was really an oversight** — you escalated something that an existing
   ADR/pattern already answered, or you *failed* to escalate something you should have.

## The mechanism

Each agent definition ends with a `## Lessons learned` section. To improve:

1. Write the lesson as a short, imperative rule — the thing future-you should *do* or *avoid*.
2. Append it under `## Lessons learned` in your **own** `.claude/agents/<you>.md`
   (Morgan edits the teamlead skill / `process/roles.md`).
3. Keep lessons specific and deduplicated. If a new lesson generalises an old one, replace it.
4. **Commit the change directly to `main`** with message:
   `chore(<agent>): learn — <one-line lesson>`
   (Self-improvement edits bypass the PR flow on purpose — they are small, low-risk identity edits.)

### Lesson format

```
- **<short title>.** <Imperative rule.> _(learned from #<issue or PR>, <date>)_
```

Example for Lena:

```
- **Match the exact requested string.** When a card quotes the exact text to add, copy it
  verbatim — don't paraphrase, translate, or "improve" it. _(learned from #1, 2026-06-04)_
```

## Team-level learning

When a lesson applies to *everyone* (a process gap, not a personal one), Morgan records it in the
relevant `process/*.md` file instead of a single agent — and, if it sets an architectural
precedent, opens an ADR. That way the whole team inherits it.

## Guardrails

- Improvement edits change **identity/instructions only** — never widen your own tool permissions
  or relax a non-negotiable rule in `CLAUDE.md`.
- Don't rewrite history or delete prior lessons unless they are wrong or superseded; prefer to
  refine.
- If you're unsure whether a lesson is right, that uncertainty is itself a `needs-decision`.
