# Workflow & status model

We work in short iterations on a GitHub Projects (v2) kanban board called **Living Artifact**
(`https://github.com/users/Hedde/projects/4`). There are two status concepts: the **board
status** (the swim lanes the card physically lives in) and the **story lifecycle** (how a piece
of work matures from a rough idea into something Ready). They are related but not the same.

## Board status (the kanban lanes — source of truth)

These are the single-select `Status` options on the project. WIP limits in parentheses come
from the board itself and are enforced by the teamlead.

```
Backlog  ──►  Ready  ──►  In progress  ──►  In review  ──►  Done
(WIP 3)                     (WIP 3)          (WIP 5)
                              ▲                  │
                              └──── rework ──────┘
```

| Lane          | Meaning                                   | Who moves the card in            |
|---------------|-------------------------------------------|----------------------------------|
| **Backlog**   | Not started; idea/refinement happens here | Human (creates) / Morgan (triage)|
| **Ready**     | Meets DoR, prioritised, safe to pick up   | **Human only** (the go-signal)   |
| **In progress** | Actively being built by specialists     | Morgan (pulls from Ready)        |
| **In review** | PR open, under review against DoD         | Morgan (after PR opened)         |
| **Done**      | PR merged, DoD satisfied                  | Morgan (after human merges PR)   |

**Allowed transitions** (anything else is invalid):

- `Backlog → Ready` — human, when DoR is met and they want it picked up.
- `Ready → In progress` — Morgan, respecting the In-progress WIP limit of 3.
- `In progress → In review` — Morgan, once a PR is open and DoD self-check passes.
- `In review → Done` — Morgan, **only after the human merges the PR**.
- `In review → In progress` — Morgan, when review finds the work is not Done (rework).
- `Any → Backlog` — Morgan, when a card is `blocked` or fails DoR and must be reworked/refined.

The human may always pull a card back, reprioritise, or drag it anywhere. Agents may only make
the transitions listed above.

## Story lifecycle (how a card matures)

A card carries a lifecycle label while it is in **Backlog**, so refinement is visible:

```
idea ──► ready-for-refinement ──► ready ──► planned
```

- **idea** — a raw thought. May be a one-liner.
- **ready-for-refinement** — has enough context for the team to refine it.
- **ready** — refined, estimated (Size field), acceptance criteria written → satisfies DoR.
- **planned** — prioritised by the human and dragged into the **Ready** lane.

These map onto the lanes like this: lifecycle `idea`/`ready-for-refinement`/`ready` all live in
the **Backlog** lane (distinguished by label); moving to the **Ready** lane is what `planned`
means. `done` corresponds to the **Done** lane.

## The loop, end to end

1. **Human** creates a card (issue) and refines it until it meets DoR, then drags it to **Ready**.
2. **Morgan** (teamlead, polling every ~5 min) sees a card in **Ready**:
   - Re-checks DoR. If it fails → comment why, label `needs-refinement`, move back to **Backlog**.
   - If In-progress WIP is at 3 → leave it; pick it up next tick.
   - Otherwise: claim it, move to **In progress**, post a short plan, and **select the expertises**
     the card needs (`process/roles.md`).
3. **Specialists** do the work on a feature branch: code/docs/tests per DoD.
4. If any specialist hits an **undecided choice or a new pattern** → escalate via `needs-decision`
   (`process/human-in-the-loop.md`); Morgan moves the card back toward the human and stops.
5. **Morgan** opens a **Pull Request**, runs the DoD self-check, moves the card to **In review**,
   and requests the human's review.
6. **Human** reviews and merges (or requests changes → Morgan moves it back to **In progress**).
7. On merge, **Morgan** moves the card to **Done** and closes the issue.
8. Throughout, any preventable mistake triggers the **self-improvement loop**
   (`process/self-improvement.md`).

## What stays with the human

- Creating and prioritising cards.
- The `Backlog → Ready` go-signal.
- Merging PRs.
- Any `needs-decision` that introduces a new pattern, tool, or product trade-off.
