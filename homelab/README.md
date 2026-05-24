# homelab/

Project-wide homelab notes and scripts that don't belong under
`home-assistant/`. Currently empty placeholder; populated as CRAWL
infrastructure lands.

Expected future contents:

- `proxmox/` — host config notes, snapshot scripts, vzdump retention
- `forgejo/` — operational notes for the Forgejo LXC (CT 100)
- `tailscale/` — ACL fragments, subnet-router LXC config if/when added
- `dev-lxc/` — Claude Code dev LXC (CT 101) setup notes, tmux session
  conventions

The corresponding architectural decisions live in `docs/decisions.md`
(ADR-007 through ADR-010). The CT/VM ID allocation and IP plan live in
`_working-memory/networkContracts.md`.
