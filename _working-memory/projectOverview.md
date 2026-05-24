# Project Overview

## What this is

An 18-month smart-home transformation built on a self-hosted Proxmox
homelab. Home Assistant runs as a VM and is the automation brain. Apple
Home is the household-facing interface. The same Proxmox host runs Forgejo
(self-hosted git, CT 100) and a dedicated Claude Code dev LXC (CT 101),
both reachable off-network via Tailscale.

Privacy-first, manual-overrides-always-work, HAF-driven (Household
Acceptance Factor).

## Stack

- Hypervisor: Proxmox VE on Intel i5-11400 / 16GB DDR4
- Smart-home brain: Home Assistant OS (VM 200)
- Homelab services: native unprivileged LXCs (no Docker by default — see ADR-009)
- Primary device protocol: Zigbee (Sonoff ZBDongle-E, USB passthrough to HA VM)
- Switches: Inovelli Blue (high-traffic) + Shelly relays (shallow boxes)
- Off-network access: Tailscale per-host for homelab; Nabu Casa for HA + Siri
- Network: VLAN-segmented (Trusted / IoT / Guest / Servers)
- Source-of-truth split: GitHub issues = tactical work; `docs/` = narrative + ADRs;
  `_working-memory/` = agent-facing routing and context

## Repository structure

```
.
├── AGENTS.md                # on-demand routing table for _working-memory/
├── CLAUDE.md                # thin pointer to AGENTS.md (kit convention)
├── README.md                # project quick-context (project-wide)
├── _working-memory/         # cross-session agent context (this file's home)
│   ├── activeContext.md     # personal sticky note (gitignored, <= 20 lines)
│   ├── projectOverview.md   # this file
│   ├── conventions.md       # PolicyRule rows (required/recommended/advisory)
│   ├── decisionLog.md       # auto-generated index of ADRs by frontmatter
│   ├── networkContracts.md  # entity naming + VLAN/IP plan + protocols
│   ├── openQuestions.md     # unresolved questions; ask, don't guess
│   └── antipatterns.md      # rejected patterns with "Don't suggest" levers
├── docs/                    # project-wide documentation
│   ├── prd.md               # full 18-month vision + architecture
│   ├── decisions.md         # ADRs (slim memory-bank frontmatter + Nygard body)
│   ├── inventory.md         # device tracking (templates only; real data offline)
│   └── phases/{crawl,walk,run}.md   # phase reading guides (thin; point at issues)
├── home-assistant/          # HA-scoped only
│   ├── CLAUDE.md            # HA-config-session instructions
│   └── docs/troubleshooting.md      # HA-specific recovery
├── homelab/                 # Proxmox / Forgejo / Tailscale notes (future scripts)
├── scripts/                 # auto-fire infra (pre-push PII gate, discipline-check,
│                            #   regen-decision-log, run-audit, session hooks)
└── .claude/                 # synchronizer + hydrator agents + skills
```

## Key constraints

- No PII in committed code. Family names, exact addresses, lock codes never
  enter tracked files. `.audit-pii-patterns` is gitignored; `scripts/git-hooks/pre-push`
  blocks pushes that match. After any `git init`, re-run
  `git config core.hooksPath scripts/git-hooks` (the hooksPath setting lives
  in `.git/config` and gets wiped by init).
- No `git commit` by automated agents. Stage, propose message, pause for the
  maintainer.
- Conventions in `_working-memory/conventions.md` are policy. `required` rules
  bind agent behavior at generation time.
- Issues are thin briefs. Don't pre-write exhaustive step-by-step procedures
  in issue bodies; they rot fast. Plan in-session via plan mode against the
  current state of the world.
