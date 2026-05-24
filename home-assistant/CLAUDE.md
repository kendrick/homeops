# CLAUDE.md

## Project

A crawl -> walk -> run approach to smart home automation. Home Assistant core, Apple Home household interface.

## Current State

- **Phase:** CRAWL (months 0-3) - See @docs/phases/crawl.md
- **Focus:** Lighting, locks, network foundation
- **HA Status:** Not yet installed

## Entity Naming

`{domain}.{floor}_{room}_{fixture}` - e.g., `light.second_bedroom_2_ceiling`

## Commands

- Build/test: HA Configuration -> Check Configuration
- Logs: Settings -> System -> Logs

## Key Constraints

- Manual overrides MUST always work
- Test automations in notification-only mode first
- Prefer Zigbee (local) over WiFi (cloud risk)
- 2-space YAML indentation, comments on complex logic
- Check HAF before suggesting automations

## Don't

- Recommend cloud-only solutions without justification
- Suggest automations that bypass manual control
- Over-engineer when simple works
- Add code style rules (use linters)

## Reference Docs

- Full requirements: @docs/prd.md
- Decisions: @docs/decisions.md
- Device inventory: @docs/inventory.md
- Troubleshooting: @docs/troubleshooting.md