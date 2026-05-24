# homeops

18-month smart home transformation centered on Home Assistant + Apple Home.

Self-hosted, privacy-first, manual-overrides-always-work.

## Quick Context

- **Location:** Fort Worth, TX
- **Owner:** Technical DIYer, UX professional, WFH
- **Household:** Multi-person, mixed technical levels
- **Current Phase:** CRAWL (months 0-3)

## Tech Stack

- **Brain:** Home Assistant OS
- **Protocol:** Zigbee primary (Sonoff ZBDongle-E)
- **Switches:** Inovelli Blue + Shelly relays
- **Interface:** Apple Home via Nabu Casa
- **Network:** VLANs (Default/IoT/Guest/Servers)

## Core Principles

1. Manual overrides always work
2. Self-hosted > cloud (exception: Nabu Casa)
3. HAF (Household Acceptance Factor) is paramount
4. Privacy-first, network-segmented
5. Test before deploying

## Project Phases

| Phase | Focus                        | Budget    | Status  |
| ----- | ---------------------------- | --------- | ------- |
| CRAWL | Lighting, locks, foundation  | $1.5-2.5k | Active  |
| WALK  | Sensors, climate, irrigation | ~$1k      | Planned |
| RUN   | Presence, blinds, UI polish  | $2-5k     | Planned |

## Directory Structure

- `docs/prd.md` - Full requirements
- `docs/decisions.md` - ADRs
- `docs/inventory.md` - Device tracking
- `docs/troubleshooting.md` - Common fixes
- `docs/phases/*.md` - Phase checklists

## For AI Agents

See CLAUDE.md for operational instructions.
Reference @docs/\*.md files as needed for specific tasks.
