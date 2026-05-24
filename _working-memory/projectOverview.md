# Project Overview

## What This Is

An 18-month smart-home transformation centered on Home Assistant as the brain and Apple Home as the household interface. Built on a self-hosted Proxmox homelab (HA OS in a VM + native-LXC services). Privacy-first, manual-overrides-always-work, HAF-driven (Household Acceptance Factor).

## Stack

- **Brain:** Home Assistant OS (VM on Proxmox VE)
- **Hypervisor:** Proxmox VE on Intel i5-11400 / 16GB DDR4
- **Homelab services:** native unprivileged LXCs (Forgejo for git on CT 100, Claude Code dev on CT 101; Docker reserved for compose-only apps)
- **Primary device protocol:** Zigbee (Sonoff ZBDongle-E)
- **Switches:** Inovelli Blue (high-traffic) + Shelly relays (shallow boxes)
- **Off-network access:** Tailscale per-host; Nabu Casa for HA + Apple Home/Siri
- **Network:** VLAN-segmented (Trusted / IoT / Guest / Servers)
- **Source-of-truth split:** GitHub issues for tactical work; `home-assistant/docs/` for narrative + ADRs; `_working-memory/` for agent-facing routing + context

## Repository Structure

```
.
├── _working-memory/          # agent-facing context (this file's home)
├── home-assistant/
│   ├── docs/
│   │   ├── prd.md            # narrative vision + architecture
│   │   ├── decisions.md      # long-form ADRs (with slim frontmatter)
│   │   ├── inventory.md      # device inventory (templates only — real data offline)
│   │   ├── troubleshooting.md
│   │   └── phases/{crawl,walk,run}.md   # phase reading guides (thin)
│   ├── CLAUDE.md             # HA-subdir-specific agent instructions
│   └── README.md             # project quick-context
├── scripts/                  # auto-fire infra: pre-push, discipline-check, regen-decision-log, etc.
├── AGENTS.md                 # on-demand routing table for _working-memory/
├── CLAUDE.md                 # root agent pointer (defers to AGENTS.md)
└── .claude/                  # synchronizer agent + skills + hooks
```

## Key Constraints

- **No PII in committed code.** Real names of household members, exact addresses, and lock codes never enter tracked files. The `.audit-pii-patterns` file is gitignored; `scripts/git-hooks/pre-push` hard-blocks pushes that match.
- **No `git commit` by agents.** Stage + propose message + pause for the maintainer to commit manually.
- **Conventions are policy, not suggestion.** See `conventions.md` — `required` rules bind agent behavior at generation time.
- **Issues are thin briefs.** Don't pre-write exhaustive step-by-step procedures in issue bodies — they rot fast. Plan in-session via plan mode.
