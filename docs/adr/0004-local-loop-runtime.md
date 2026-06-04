# ADR-0004 — Local `/loop` runtime

- **Status:** Accepted
- **Date:** 2026-06-04

## Context

The teamlead must observe the board roughly every 5 minutes and act. Options considered:

1. **Local `/loop` session** — run `/loop 5m /teamlead` in a Claude Code session on the human's
   machine. Zero infrastructure. Runs only while the session is open.
2. **GitHub Actions cron** — runs in the cloud 24/7. Requires storing an Anthropic API key as a
   repo secret and a CI harness.
3. **Remote scheduled agent (routine)** — Anthropic-hosted cron. Requires remote-agent setup.

## Decision

Start with the **local `/loop` session** (option 1). It matches the "hello-world / demo" stage,
needs no secrets or infrastructure, and keeps the human naturally close to the loop.

## Consequences

- The team only progresses work while a human has the loop running. This is acceptable now and is a
  feature for a demo (the human is present).
- Moving to 24/7 autonomy later is a deliberate, ADR-gated step (would supersede this ADR) — likely
  GitHub Actions, which the repo's `workflow` token scope already anticipates.
- No secret management is required at this stage.
