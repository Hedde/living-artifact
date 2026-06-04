# Human-in-the-loop protocol

The human's time is spent on **prioritising** and on **decisions that have not been made yet**.
Everything else runs autonomously. This document defines exactly when and how the team hands a card
back to the human.

## When to escalate

Escalate (hand back to the human) whenever continuing would mean **inventing a decision that isn't
recorded**, specifically:

1. **A new pattern** — architectural, structural, or a design approach not already used here.
2. **A new tool or dependency** — anything that adds to the project's toolchain or supply chain.
3. **A new UI/UX pattern** — a novel interaction, layout, or component approach.
4. **A product trade-off** — scope, priority, or behaviour the acceptance criteria don't settle.
5. **Ambiguity in the acceptance criteria** that can't be resolved by reading the card.

If a choice is *already* settled (an existing pattern, an ADR, an explicit criterion), do **not**
escalate — just proceed.

## How to escalate (`needs-decision`)

When a specialist hits one of the above, Morgan does the following on the card:

1. **Comment** with a structured decision request:
   ```
   🤚 Decision needed — <one-line summary>

   Context: <why this came up>
   Options:
     A) <option> — <trade-off>
     B) <option> — <trade-off>
   Preference: <A/B> because <reason>.   ← the team always states a recommendation
   Blocks: <what cannot proceed until this is decided>
   ```
2. **Label** the card `needs-decision`.
3. **Assign** the card to the human (`Hedde`).
4. **Move** the card back to **In progress** is *not* done — instead leave it where it is and stop
   working it; if it was mid-build, note the safe stopping point in the comment.
5. **Stop.** Do not implement the chosen option until the human answers.

> The team always expresses a **preference** with a reason. It never escalates with an open-ended
> "what do you want?" — it proposes, the human disposes.

## How the human responds

- The human replies in the card comment with the chosen option (and, if it sets a new precedent,
  the team records it as an **ADR** under `docs/adr/` as part of the work — see
  `docs/adr/0001-record-architecture-decisions.md`).
- Morgan removes the `needs-decision` label and resumes the card.

## Other human gates (no label needed)

- **`Backlog → Ready`** — only the human gives the go-signal.
- **Merging PRs** — only the human merges feature work.

## Labels used by this protocol

| Label              | Meaning                                                        |
|--------------------|----------------------------------------------------------------|
| `needs-decision`   | Blocked on a human decision (new pattern/tool/UX/trade-off).   |
| `needs-refinement` | Failed DoR; sent back to Backlog to be refined.                |
| `blocked`          | Blocked by an external dependency.                             |
| `story`            | A user story card.                                             |
| `idea` / `ready-for-refinement` / `ready` | Story lifecycle within Backlog.         |
