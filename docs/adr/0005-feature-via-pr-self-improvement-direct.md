# ADR-0005 — Feature work via PR, self-improvements direct to main

- **Status:** Accepted
- **Date:** 2026-06-04

## Context

Two kinds of change flow through this repo: (a) **feature/documentation work** driven by board
cards, and (b) **agent self-improvement** edits to agent identities. They have very different risk
profiles. We must decide how each reaches `main` and where the human gates sit.

Separately, the **backbone/template itself** (process docs, agent definitions, tools, this ADR) is
being bootstrapped by a human + Claude directly, not as board cards.

## Decision

- **Feature & documentation work** (anything that satisfies a board card) ships via a **Pull
  Request that the human merges.** The `In review` lane is the review gate; `In review → Done`
  happens only after merge. Agents never merge feature PRs.
- **Agent self-improvement edits** are committed **directly to `main`** (small, low-risk identity
  edits — see `process/self-improvement.md`).
- **Backbone/template changes** (process, agents, tooling, docs that are *not* a board card) are
  made **directly** by the human + Claude, without a card and without a PR. Only functional product
  work goes through the board workflow.

## Consequences

- The human stays in control of what lands as product behaviour, via the merge gate.
- Agents can still evolve themselves quickly without PR overhead.
- The distinction must be applied honestly: if a "self-improvement" actually changes product
  behaviour, it is feature work and goes via PR. When unsure, treat it as feature work.
- Bootstrapping the framework stays fast and friction-free; once the framework exists, product work
  is disciplined by the board.
