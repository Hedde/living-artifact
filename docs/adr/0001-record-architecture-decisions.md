# ADR-0001 — Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-06-04

## Context

The team is forbidden from introducing new patterns, tools, or UI/UX approaches without agreement
(see `CLAUDE.md`, rule 4). For that rule to be enforceable, agreed decisions must be written down
somewhere durable and discoverable — otherwise "already decided" is unknowable and every choice
becomes a fresh escalation.

## Decision

We keep **Architecture Decision Records (ADRs)** as numbered Markdown files in `docs/adr/`. Each
records one decision: its context, the decision, and its consequences. ADRs are immutable once
Accepted; to change one, write a new ADR that supersedes it.

A decision needs an ADR when it sets a precedent: a pattern, a tool/dependency, a structural
choice, or a product-shaping trade-off. Trivial, local choices do not.

New ADRs are created as part of normal work (often as the outcome of a `needs-decision`
escalation) and use [`template.md`](template.md).

## Consequences

- "Is this already decided?" has a single place to look.
- The `needs-decision` protocol has a natural home for its outcomes.
- A small amount of writing overhead per real decision — accepted as worth it.
