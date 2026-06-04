# ADR-0002 — GitHub Projects as the source of truth

- **Status:** Accepted
- **Date:** 2026-06-04

## Context

The team needs one authoritative place that says what work exists and what state it is in. Options
considered: a file in the repo, an external task tracker, or GitHub Projects (v2). The human already
works on a GitHub Projects board (#4) and wants to stay in the loop there.

## Decision

**GitHub Projects #4 is the single source of truth for work state.** Issues are cards; the project's
`Status` single-select field defines the kanban lanes. The team reads and writes board state only
through `tools/board.sh` (gh GraphQL). No parallel or hidden task state is kept anywhere else.

## Consequences

- The human and the agents see the same board; no syncing problem.
- Requires a `gh` token with the `project` scope.
- We depend on GitHub's GraphQL API and the project/field IDs in `tools/board.env`; if the board is
  recreated, those IDs must be refreshed.
- Polling (not webhooks) is used to observe changes — see ADR-0004.
