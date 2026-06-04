# Architecture (living document)

> Keep this file true. It is part of the Definition of Done: any change that alters structure
> updates this page in the same Pull Request.

## What this is

**Living Artifact** is a project/stack-agnostic template for running an *agile AI software team*
on top of GitHub. There is (deliberately) no application code yet — the "product" right now is the
**way of working** itself. A real project's code is added later, behind ADRs.

## System overview

```
            ┌──────────────────────────────────────────────────────────┐
            │                     GitHub                                 │
            │   Repo: Hedde/living-artifact   Project #4: Living Artifact│
            │   Issues = cards · Status field = kanban lanes             │
            └───────────────▲───────────────────────────┬──────────────┘
                            │ gh CLI / GraphQL           │ webhook-free polling
                            │ (tools/board.sh)           │
            ┌───────────────┴───────────────────────────▼──────────────┐
            │            Claude Code session  (local /loop 5m)          │
            │                                                            │
            │   Morgan — teamlead skill (.claude/skills/teamlead)       │
            │     • polls board   • checks DoR/DoD   • routes expertise │
            │     • moves cards   • opens PRs        • escalates        │
            │                          │ spawns                         │
            │                          ▼                                │
            │   Specialist subagents (.claude/agents/*.md)              │
            │     Bob · Fiona · Daryl · Claudia · Sam · Priya · Lena ·  │
            │     Quentin   — each with skills + a Lessons-learned log   │
            └────────────────────────────────────────────────────────────┘
```

## Key components

| Component            | Where                          | Responsibility                              |
|----------------------|--------------------------------|---------------------------------------------|
| Board adapter        | `tools/board.sh`               | All reads/writes to Project #4 via GraphQL. |
| Board config (IDs)   | `tools/board.env`              | Project/field/option IDs (no secrets).      |
| Teamlead             | `.claude/skills/teamlead/`     | The poll-and-orchestrate routine (Morgan).  |
| Specialists          | `.claude/agents/*.md`          | Domain work; self-improving identities.     |
| Process              | `process/*.md`                 | Workflow, DoR, DoD, HITL, self-improvement. |
| Decisions            | `docs/adr/*.md`                | Architecture Decision Records.              |
| Feature docs         | `docs/features/*.md`           | User-facing behaviour, written as part of DoD. |

## Runtime model

- A human runs `/loop 5m /teamlead` in a Claude Code session on their machine.
- Each tick, Morgan reconciles board state and advances cards as far as the rules allow.
- Autonomy is bounded by the rules in `CLAUDE.md`; the human gates Ready, decisions, and merges.
- Because it polls (no webhooks/servers), there is no always-on infrastructure to operate. The
  trade-off — it only runs while the session is open — is recorded in
  [`docs/adr/0004-local-loop-runtime.md`](adr/0004-local-loop-runtime.md).

## Source of truth

GitHub Projects #4 is authoritative for *what state work is in*. The repo is authoritative for
*the work itself* (code, docs, agent identities). Neither the teamlead nor specialists keep hidden
state — everything is on the board or in the repo.

## Decisions index

See [`docs/adr/`](adr/). Current ADRs:

- ADR-0001 — Record architecture decisions
- ADR-0002 — GitHub Projects as the source of truth
- ADR-0003 — Agents as Claude Code subagents
- ADR-0004 — Local `/loop` runtime
- ADR-0005 — Feature work via PR, self-improvements direct to main
