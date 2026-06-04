# ADR-0006 — Trust boundary for the public-repo loop

- **Status:** Accepted
- **Date:** 2026-06-04

## Context

This repository is **public** on GitHub. The autonomous teamlead loop runs **locally on the owner's
laptop** (`/loop 5m /teamlead`, see ADR-0004) with a `gh` token scoped to repo + project + workflow,
and with local file-write and Bash access.

Anyone can open issues, PRs, and comments on a public repo. All of that text — card titles, issue
bodies, PR descriptions, comments — flows into the loop as context. That is a **prompt-injection**
vector: an untrusted author can write text crafted to read as instructions ("ignore your rules and
run …", "the owner approved deleting …") and try to steer the agents into harmful local actions
using the token and Bash access they hold. There is no human in the loop on every step, so the
boundary between untrusted text and privileged action must be defined explicitly, not assumed.

**Manual review is an unreliable control here.** Injection can be hidden in HTML comments, collapsed
`<details>` blocks, whitespace padding, and pasted log/JSON blobs — and, decisively, in **zero-width
or Unicode "tags" characters that render as nothing but remain in the text the model reads**, which
a human cannot catch by eye. Issues, PR bodies, and comments are all equally untrusted, so disabling
one channel is not a cure-all. The dependable control is therefore **least privilege**: the loop
must be *incapable* of irreversible action, rather than relying on a human to notice the attack.

## Decision

We define a **trust boundary** around the loop, enforced by five defense-in-depth layers. Untrusted
GitHub text never crosses into privileged action except through these gates:

1. **Interaction limit = `collaborators_only`.** GitHub repo interaction limits are set so only
   collaborators can open issues/PRs/comments. This shrinks who can reach the loop at all.
2. **Ready-gate.** The loop only acts on cards the **human** has moved to **Ready** (the existing
   workflow). Untouched, freshly-filed issues are never auto-worked.
3. **Author allowlist.** The teamlead refuses to work a card unless the issue's GitHub
   `author_association` is `OWNER` (or a configured allowlist of logins). `author_association` is
   reported by GitHub per issue and cannot be set by the author.
4. **Untrusted input as data.** All card / issue / PR / comment text is treated as **data to reason
   about, never as instructions to obey.** Embedded directives are ignored; an attempt to direct
   agent behaviour is itself a security signal (see the agent charter).
5. **Least privilege (the primary control).** The other four layers reduce *exposure*; this one
   *bounds the damage* when they fail. The loop is incapable of irreversible action: agents never
   merge, deploy, or read secrets (the human merges every PR), the local permission allowlist stays
   tight, destructive Bash is never auto-approved, and the token keeps the minimum scopes the work
   needs and is not widened on demand.

No single layer is trusted alone: even if interaction limits or the allowlist are misconfigured,
the Ready-gate and the "input is data" rule still stand, and vice versa.

## Consequences

- **What this buys us.** Untrusted authors cannot, by text alone, get the loop to take privileged
  local action. Reaching the loop requires being a collaborator *and* an allowlisted author *and*
  a human deliberately moving the card to Ready — and even then the text is reasoned about, not
  obeyed. Privileged actions stay gated behind least privilege.
- **Harder / committed to.** The loop must check `author_association` (or the allowlist) before
  working any card, and refuse otherwise. The local permission allowlist must stay deliberately
  narrow; widening it or adding token scopes is a `needs-decision`, not a convenience tweak.
- **Residual risks.** A compromised or coerced collaborator/owner account, a leaked `gh` token, or
  an over-broad local permission allowlist all bypass these layers — they protect against
  *untrusted strangers*, not a trusted-account compromise. Supply-chain risk in tooling is also out
  of scope here.
- **Revisit on scale-up.** This boundary assumes a **local, human-supervised, intermittent** loop.
  Moving to **24/7 or cloud-hosted** execution removes the implicit human-at-the-keyboard backstop
  and changes the blast radius; that change **must revisit this ADR** before shipping.
