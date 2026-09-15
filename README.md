```
██╗  ██╗ ██████╗ ███╗   ███╗███████╗ ██████╗ ██████╗ ███████╗
██║  ██║██╔═══██╗████╗ ████║██╔════╝██╔═══██╗██╔══██╗██╔════╝
▓▓▓▓▓▓▓║▓▓║   ▓▓║▓▓╔▓▓▓▓╔▓▓║▓▓▓▓▓╗  ▓▓║   ▓▓║▓▓▓▓▓▓╔╝▓▓▓▓▓▓▓╗
▒▒╔══▒▒║▒▒║   ▒▒║▒▒║╚▒▒╔╝▒▒║▒▒╔══╝  ▒▒║   ▒▒║▒▒╔═══╝ ╚════▒▒║
░░║  ░░║╚░░░░░░╔╝░░║ ╚═╝ ░░║░░░░░░░╗╚░░░░░░╔╝░░║     ░░░░░░░║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝

```

# homeops

The decisions and dead ends behind an 18-month smart-home build.

A self-hosted smart home on top of a Proxmox homelab. Home Assistant is the brain; Apple Home is the household interface. The homelab also hosts Forgejo for self-hosted git and a dedicated dev LXC for running Claude Code.

Self-hosted, privacy-first.

## What's not here

This repo is public, so the household itself stays out of it. No real names, no street address, no lock codes, no photos, no actual IPs. `docs/inventory.md` ships templates, not the device list. `scripts/git-hooks/pre-push` sweeps for the tokens listed in `.audit-pii-patterns` and blocks the push on a match.

It's also one household's build. The patterns might transfer; the wiring won't.

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

| Phase | Focus                                | Status  |
| ----- | ------------------------------------ | ------- |
| CRAWL | Lighting, locks, network, foundation | Active  |
| WALK  | Sensors, climate, irrigation         | Planned |
| RUN   | Presence, blinds, UI polish          | Planned |

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

## Working on a fresh clone

Three setup steps, all of which fail silently if you skip them:

```bash
git config core.hooksPath scripts/git-hooks           # arms the pre-push gate
cp .audit-pii-patterns.example .audit-pii-patterns    # then add your real tokens
cp .env.example .env                                  # then edit the vault paths
```

Without the first, the PII sweep never runs and git gives you no warning. `core.hooksPath` lives in `.git/config`, so `git init` wipes it. Re-run the command after any re-init.

The pattern file is gitignored, so a fresh clone has none. Until you write real tokens into it, `audit-pii.sh` prints `no patterns configured` and exits clean. The hook still runs; it just has nothing to match.

Without the third, `sync-to-vault.sh` and `sync-from-vault.sh` become no-ops and the session-start hook skips its vault check. Run either script directly and it at least prints a configure-me message; the hook just skips.

## For AI agents

The canonical entry point is `AGENTS.md` at the repo root. It contains the on-demand routing table for `_working-memory/`. Read `_working-memory/activeContext.md` at session start; read other working-memory files when the table directs you to.

For HA-config-specific sessions (editing automations, dashboards, YAML), the additional instructions at `home-assistant/CLAUDE.md` apply.

## Contributing

Not taking pull requests. The repo tracks one specific house, so there's no version of a merge that helps both of us. Issues and questions are welcome, though, especially about the working-memory setup or the PII gate.

## License

MIT. See [LICENSE](LICENSE).
