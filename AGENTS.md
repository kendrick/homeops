# AGENTS.md

## Stack

<!-- One line per layer. Detected from project. -->

## Build / Test / Lint

<!-- Copy exact commands so agents don't guess. -->

## Working Memory

This project uses a two-tier working memory at `_working-memory/`.

**AGENT INSTRUCTION:** scan this section BEFORE deciding what to read. If your task matches a row in the on-demand table, that file is required reading before you proceed.

### Always read on session start:

- `_working-memory/activeContext.md` — Current focus, last decision, known risks (≤20 lines, local only / gitignored)

### Read on demand:

| File                   | Read when...                                                                                                      |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `projectOverview.md`   | Starting a new feature or onboarding                                                                              |
| `decisionLog.md`       | Quick chronological index of decisions (auto-generated from `docs/decisions.md` frontmatter)        |
| `networkContracts.md`  | Touching entity naming, VLAN/IP assignments, or device-protocol selection                                          |
| `conventions.md`       | Writing new code/config or reviewing patterns (PolicyRule rows with required/recommended/advisory)                |
| `openQuestions.md`     | Encountering ambiguity — check here before guessing                                                               |
| `antipatterns.md`      | BEFORE suggesting a refactor, library swap, or architectural change — check whether it's already been rejected    |

### Where new content goes (placement table)

Before creating any new file, consult this table. If the file's purpose doesn't match a row, ask before writing rather than guessing a location. This table is the primary defense against subdirectories drifting into misnomers (as `home-assistant/` did before its 2026-05 restructure).

| New content                                                  | Goes in                                                                                                                          |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| Architectural decision (real choice, alternatives)           | `docs/decisions.md` — append a new ADR with slim frontmatter; the `Stop` hook regenerates `_working-memory/decisionLog.md`       |
| Project-wide narrative doc                                   | `docs/`                                                                                                                          |
| Phase reading guide                                          | `docs/phases/`                                                                                                                   |
| Device inventory entry                                       | `docs/inventory.md`                                                                                                              |
| HA config (YAML automations, dashboards, custom components)  | `home-assistant/`                                                                                                                |
| HA-specific troubleshooting                                  | `home-assistant/docs/troubleshooting.md`                                                                                         |
| Proxmox / Forgejo / Tailscale / dev-LXC notes or scripts     | `homelab/`                                                                                                                       |
| Convention / PolicyRule                                      | `_working-memory/conventions.md`                                                                                                 |
| Unresolved question                                          | `_working-memory/openQuestions.md`                                                                                               |
| Rejected pattern with reason                                 | `_working-memory/antipatterns.md`                                                                                                |
| Network plan / protocol assignments / entity-naming grammar  | `_working-memory/networkContracts.md`                                                                                            |
| Auto-fire script                                             | `scripts/`                                                                                                                       |
| Git hook                                                     | `scripts/git-hooks/`                                                                                                             |
| Cross-session memory (user profile, project state, feedback) | `~/.claude/projects/-Users-karnett-repos-homeops/memory/` (NOT in repo)                                                          |
| Session-ritual skill (slash command for a recurring workflow) | `.claude/skills/<name>/SKILL.md` (e.g. `/start-issue` lives at `.claude/skills/start-issue/SKILL.md`)                            |
| Anything sensitive (real names, real IPs, lock codes, photos) | NOT in this repo — local-only or a private companion repo                                                                       |

### Updating working memory:

- After completing a feature or making a significant decision, update `activeContext.md` and the relevant on-demand file.
- `activeContext.md` is a queue: evict completed items to `decisionLog.md`.
- `decisionLog.md` and `antipatterns.md` are both append-only. Never edit past entries.
- Never let `activeContext.md` exceed 20 lines.

## Conventions

<!-- Populated from detection or manually. Keep to ≤10 rules. -->
