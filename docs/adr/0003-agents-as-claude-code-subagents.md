# ADR-0003 — Agents as Claude Code subagents

- **Status:** Accepted
- **Date:** 2026-06-04

## Context

The team is a set of named specialists with distinct expertise that must (a) be invokable
independently, (b) carry their own identity/skills, and (c) edit themselves over time
(self-improvement). We need a concrete representation for "an agent".

## Decision

Each specialist is a **Claude Code subagent** defined as a Markdown file in `.claude/agents/`
with YAML front-matter (`name`, `description`, `tools`) and a system-prompt body that contains the
agent's identity, skills, working rules, and a `## Lessons learned` section.

The **teamlead (Morgan)** is not a subagent but a **skill** (`.claude/skills/teamlead/`) executed
in the main session under `/loop`, because the teamlead orchestrates and spawns the others.

## Consequences

- Agents are version-controlled, diff-able, and reviewable like any other code.
- Self-improvement is just an edit + commit to the agent's own file.
- Morgan can delegate to specialists via the Agent tool, selecting only the expertise a card needs.
- We are coupled to Claude Code's subagent/skill format; a future move to another runner would
  require a new ADR and a translation layer.
