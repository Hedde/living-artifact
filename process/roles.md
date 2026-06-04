# Roles, expertise & dynamic team selection

The team is a roster of named specialists. Morgan (teamlead) does **not** put the whole team on
every card — that wastes effort and muddies ownership. Instead Morgan reads each card and selects
the **minimum set of expertises** the work actually needs.

## Roster

| Name    | Expertise            | Pick when the card involves…                                       |
|---------|----------------------|-------------------------------------------------------------------|
| Morgan  | Teamlead / Scrum Master | Always — facilitates, never does the specialist work itself.   |
| Bob     | Backend Developer    | APIs, data, services, business logic, server-side behaviour.      |
| Fiona   | Frontend Developer   | UI implementation, client-side behaviour, components, styling.    |
| Daryl   | UX Specialist        | Flows, layout, copy-for-users, accessibility, interaction design. |
| Claudia | Compliance Officer   | Privacy, licensing, data handling, policy, regulatory wording.    |
| Sam     | Security Expert      | Auth, secrets, input handling, threat surface, dependencies.      |
| Priya   | Performance Engineer | Latency, throughput, resource use, scaling, hot paths.            |
| Lena    | Linguist             | Documentation prose, naming, tone, translations, README/wording.  |
| Quentin | QA / Test Automation | Test design, automation, edge cases, regression coverage.         |

## How Morgan selects expertise (routing heuristic)

For each Ready card, Morgan classifies the work and pulls in only the matching specialists:

1. **Read the card** — title, body, acceptance criteria, labels, touched areas.
2. **Tag the work** with one or more domains: `backend`, `frontend`, `ux`, `compliance`,
   `security`, `performance`, `docs/linguistics`, `qa`.
3. **Map domains → specialists** using the table above.
4. **Always add Quentin** when the change is testable in code (he owns the test gate of DoD).
5. **Always add Lena** when the change touches user-facing text or docs (docs are part of DoD).
6. **Add Sam** whenever auth, secrets, external input, or new dependencies appear — never skip
   security to go faster.
7. **Keep it minimal.** If a card is "add a sentence to the README", the right team is **Lena**
   (prose) with Quentin verifying the acceptance criterion — not the whole roster.

Morgan records the chosen team in a comment on the card when moving it to **In progress**, so the
selection is transparent and auditable.

## Boundaries

- Specialists do the work; Morgan orchestrates, sequences, and integrates.
- A specialist who realises a different/extra expertise is needed tells Morgan rather than
  overstepping into another domain.
- Nobody introduces a new pattern, tool, or dependency alone — that is always a `needs-decision`
  for the human (`process/human-in-the-loop.md`).
