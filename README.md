# homeops

An 18-month project to build a self-hosted smart home on top of a Proxmox
homelab. Home Assistant is the brain. Apple Home is the household interface.
The homelab also hosts Forgejo for self-hosted git and a dedicated dev LXC
for running Claude Code off-laptop.

Self-hosted, privacy-first, manual-overrides-always-work.

## Quick context

- Location: Fort Worth, TX
- Owner: technical DIYer, UX professional, working from home
- Current phase: CRAWL (months 0-3)
- Host: Proxmox VE on an Intel i5-11400 / 16GB box
- Public repo (this one) for architecture and documentation; real device
  data (entity names, codes, photos) stays out of git

## Tech stack

- Hypervisor: Proxmox VE
- Smart-home brain: Home Assistant OS (VM on Proxmox)
- Homelab services: native unprivileged LXCs (Forgejo on CT 100; Claude
  Code dev on CT 101)
- Primary device protocol: Zigbee (Sonoff ZBDongle-E)
- Switches: Inovelli Blue (high-traffic) + Shelly relays (shallow boxes)
- Household interface: Apple Home via Nabu Casa
- Off-network access: Tailscale per-host; Nabu Casa for HA + Siri
- Network: VLAN-segmented (Trusted / IoT / Guest / Servers)

## Core principles

1. Manual overrides always work
2. Self-hosted over cloud (with documented exceptions: Nabu Casa, Tailscale)
3. HAF (Household Acceptance Factor) is paramount
4. Privacy-first, network-segmented
5. Test before deploying

## Project phases

| Phase | Focus                                | Budget    | Status  |
| ----- | ------------------------------------ | --------- | ------- |
| CRAWL | Lighting, locks, network, foundation | $1.5-2.5k | Active  |
| WALK  | Sensors, climate, irrigation         | ~$1k      | Planned |
| RUN   | Presence, blinds, UI polish          | $2-5k     | Planned |

## Repository layout

```
.
├── AGENTS.md                # routing table for _working-memory/
├── CLAUDE.md                # thin pointer to AGENTS.md (kit convention)
├── README.md                # this file
├── _working-memory/         # agent-facing context (cross-session)
├── docs/                    # project-wide documentation
│   ├── prd.md               # full requirements
│   ├── decisions.md         # ADRs (slim memory-bank frontmatter + Nygard body)
│   ├── inventory.md         # device tracking (templates only — real data offline)
│   └── phases/{crawl,walk,run}.md   # phase reading guides
├── home-assistant/          # HA-scoped only
│   ├── CLAUDE.md            # HA-config-session instructions
│   └── docs/troubleshooting.md      # HA-specific recovery
├── homelab/                 # Proxmox / Forgejo / Tailscale notes (future scripts)
├── scripts/                 # auto-fire discipline infra (PII gate, audit, hooks)
└── .claude/                 # synchronizer + hydrator agents + skills
```

## For AI agents

The canonical entry point is `AGENTS.md` at the repo root. It contains the
on-demand routing table for `_working-memory/`. Read `_working-memory/activeContext.md`
at session start; read other working-memory files when the table directs you to.

For HA-config-specific sessions (editing automations, dashboards, YAML),
the additional instructions at `home-assistant/CLAUDE.md` apply.

## License

MIT. See [LICENSE](LICENSE).
