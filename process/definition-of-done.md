# Definition of Done (DoD)

A card may only move to **Done** when **all** of the following are true. Morgan runs this as a
self-check before opening the PR and again before moving `In review → Done`. The human's merge is
the final gate.

## Checklist

- [ ] **Acceptance criteria met.** Every criterion on the card is demonstrably satisfied.
- [ ] **Tests.** Behaviour is covered by automated tests where a test framework exists. For this
      stack-agnostic template, "tests" may be a documented manual verification until an ADR
      introduces a framework. No regressions.
- [ ] **Reviewed.** The change was reviewed against this DoD (by a reviewer agent and/or the human).
      Review comments are resolved.
- [ ] **Feature documentation updated.** A page under `docs/features/` describes the behaviour from
      the user's perspective (what it does, how to use it).
- [ ] **Architecture documentation updated.** If the change touches structure, `docs/architecture.md`
      reflects reality. If it introduces a decision, an ADR exists under `docs/adr/`.
- [ ] **No undecided new patterns.** Nothing new (pattern/tool/dependency/UX) was added without an
      agreed ADR. If a new pattern was needed, it was resolved via `needs-decision`.
- [ ] **Clean delivery.** Work is on a feature branch with a clear PR description that links the
      issue (`Closes #N`), explains the change, and notes any follow-ups.
- [ ] **Board updated.** The card's status reflects reality and the issue is closed on merge.
- [ ] **Lessons captured.** Any preventable mistake found during the work or its review was fed back
      into the responsible agent's definition (`process/self-improvement.md`).

## The merge gate

Feature and documentation work reaches `main` **only through a Pull Request the human merges**.
Morgan never merges feature PRs. When the human merges, Morgan moves the card to **Done** and closes
the issue.

(Agent self-improvement edits are the one exception — they go straight to `main`, see
`process/self-improvement.md`.)
