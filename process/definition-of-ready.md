# Definition of Ready (DoR)

A card may only enter **Ready** (and therefore be picked up by the team) when **all** of the
following are true. Morgan re-checks this before pulling a card into **In progress**; if any item
fails, the card is labelled `needs-refinement`, commented on, and moved back to **Backlog**.

## Checklist

- [ ] **User story format.** The card describes the work as *“As a `<role>`, I want `<goal>`, so
      that `<benefit>`.”*
- [ ] **Acceptance criteria.** At least one concrete, testable criterion is written (Given/When/Then
      or a bullet list). It is unambiguous what "done" looks like from the outside.
- [ ] **Sized.** The `Size` field is set (XS–XL). Anything bigger than L should be split first.
- [ ] **Self-contained.** No unresolved external dependency or blocker. If there is one, the card is
      `blocked`, not Ready.
- [ ] **No undecided patterns.** The story does not *require* a new architectural pattern, tool,
      dependency, or UI/UX pattern that has not been agreed in an ADR. If it might, that decision is
      raised and resolved (or explicitly deferred) **before** the card is Ready.
- [ ] **Expertise is knowable.** It is possible to tell from the card which skills are needed
      (backend, frontend, UX, security, performance, compliance, linguistics, QA — see
      `process/roles.md`).
- [ ] **Prioritised by the human.** The human has set a `Priority` and chosen to drag it into Ready.

## Example (issue #1)

> *As a product owner, I want to add a sentence to the README.md so that I can test our work
> process. The sentence is “Dit is een geslaagde test”.*

- Story format ✅
- Acceptance criterion: *README.md contains the exact line “Dit is een geslaagde test”.* ✅
- Size: XS ✅
- Self-contained ✅ · No new pattern ✅ · Expertise: Linguist/docs ✅

This card satisfies DoR and is a valid first pull.
