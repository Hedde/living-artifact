# living-artifact

A **living artifact**: a self-improving, agile AI software team that runs on a GitHub Projects
kanban board. Named specialist agents pick work off the board, take it through a fixed status flow
under a Definition of Ready and Definition of Done, ship it via Pull Requests, and **edit their own
identities** when they learn something.

This repository is, for now, a project/stack-agnostic **template** — the "product" is the way of
working itself. Real application code is added later, behind agreed decisions (ADRs).

## How it works

```
Human creates & prioritises cards ──► drags to "Ready"
        │
        ▼
Morgan (teamlead) polls every ~5 min ──► checks DoR ──► routes the right specialists
        │                                                    │
        ▼                                                    ▼
   moves card through:  Backlog ► Ready ► In progress ► In review ► Done
        │                                                    │
        ├─ undecided choice / new pattern? ──► hands back to the human (needs-decision)
        └─ on finish: opens a PR ──► human merges ──► card → Done
```

- **Team:** Morgan (teamlead), Bob (backend), Fiona (frontend), Daryl (UX), Claudia (compliance),
  Sam (security), Priya (performance), Lena (linguist), Quentin (QA). See `process/roles.md`.
- **Source of truth:** [GitHub Project #4](https://github.com/users/Hedde/projects/4).
- **Process:** `process/` (workflow, DoR, DoD, human-in-the-loop, self-improvement).
- **Decisions:** `docs/adr/`. **Architecture:** `docs/architecture.md`.

## Quickstart

Prerequisites: `gh` authenticated with the **`project`** scope, and `jq`.

```bash
gh auth refresh -h github.com -s project   # one-time, if not already granted
./tools/board.sh items                     # see the board
```

Run the team (local runtime — see ADR-0004):

```
/loop 5m /teamlead
```

Each tick, Morgan reconciles the board and advances work as far as the rules allow. You stay in the
loop on **prioritising**, on any **needs-decision**, and on **merging PRs**.

## What's where

| Path                  | What                                                     |
|-----------------------|----------------------------------------------------------|
| `CLAUDE.md`           | Operating rules every session must follow.               |
| `process/`            | The agile process: workflow, DoR, DoD, HITL, self-improve.|
| `.claude/agents/`     | The specialist agents (self-improving identities).       |
| `.claude/skills/teamlead/` | Morgan's per-tick orchestration runbook.            |
| `tools/board.sh`      | The only adapter to the GitHub Project board.            |
| `docs/architecture.md`| Living architecture document.                            |
| `docs/adr/`           | Architecture Decision Records.                           |
| `docs/features/`      | User-facing feature documentation (part of Done).        |
