# CLAUDE.md (home-assistant scope)

Scope of this file: instructions that apply when a session is working
inside `home-assistant/` (HA configuration, custom dashboards, troubleshooting
HA-side issues). For project-wide context, the root `AGENTS.md` is the
canonical pointer to `_working-memory/`.

## Project

A crawl -> walk -> run approach to smart-home automation. Home Assistant
runs as a VM on a Proxmox homelab; Apple Home is the household interface.

## Current state

- Phase: CRAWL (months 0-3). See @../docs/phases/crawl.md
- Focus: lighting, locks, network foundation
- HA status: not yet installed

## Entity naming

`{domain}.{floor}_{room}_{fixture}`, e.g. `light.second_bedroom_2_ceiling`.
Full grammar in @../_working-memory/networkContracts.md.

## Commands

- Check config: HA Configuration -> Check Configuration
- Logs: Settings -> System -> Logs

## Key constraints

- Manual overrides MUST always work
- Test automations in notification-only mode for 48h before action-enabled
- Prefer Zigbee (local) over WiFi (cloud risk)
- 2-space YAML indentation; comments on non-obvious logic
- Check HAF before suggesting automations

## Don't

- Recommend cloud-only solutions without justification
- Suggest automations that bypass manual control
- Over-engineer when simple works
- Add code style rules (use linters)

## Reference docs

- Full requirements: @../docs/prd.md
- Decisions: @../docs/decisions.md
- Device inventory: @../docs/inventory.md
- Troubleshooting (HA-specific): @docs/troubleshooting.md
- Conventions / PolicyRules: @../_working-memory/conventions.md
- Antipatterns: @../_working-memory/antipatterns.md