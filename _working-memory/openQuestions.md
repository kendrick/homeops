# Open Questions

<!-- Things that are unresolved and should not be guessed at. -->
<!-- Agents encountering these should ask rather than assume. -->
<!-- When answered: move resolution to decisionLog.md (via an ADR if -->
<!-- architectural) or delete if it became moot. -->

## Infrastructure

- **activeContext.md sync between laptop and future dev-LXC.** activeContext.md is gitignored / per-machine. Once Claude Code is running on `dev01` (CT 101) too, both machines have their own. Options: accept per-machine drift; Tailscale-based scp on session-end; private gist; or treat the dev-LXC as the canonical workstation. Decide before CT 101 is heavily used.
- **Tailscale subnet routing strategy.** Per-host install (current ADR-008 default) covers the LXCs themselves. A subnet-router LXC would let off-network access reach _any_ LAN device. Decide when there's a concrete need (likely Walk phase, mobile access to HA web UI without Nabu Casa).
- **Tailscale account identity.** Tailscale free tier ties to a personal Google/Apple/GitHub account. Question: keep on the same account as personal tailnet, or spin up a separate identity for homeops? Affects: blast radius if account compromised, ACL complexity.
- **Private companion repo for real data.** Should `kendrick/homeops-private` exist for actual entity names, real IPs, lock codes, photos? Standard HA-community pattern. Decide before any real device data needs persistence.
- **Outage frequency tracking — trigger to revisit whole-home backup.** Track grid events informally over the next 1-2 months (rough count + duration). Revisit ADR-011 if either of these fires: more than one outage per month sustained longer than 4 hours, or cumulative downtime in any 90-day window exceeds 12 hours. Otherwise the UPS-only posture stands; the F3800-class portable becomes the next candidate, not whole-home battery.

## Public release

- **When to flip `kendrick/homeops` to public after first scrubbed push?** Options: immediately (after Phase H verification); wait a few days to see if anything rots; wait until WALK phase has substantive content. Default: immediately, since the cleanup discipline is the value.
- **`/schedule` quarterly audit setup.** Interactive setup pending (Claude Code session, `/schedule` skill). Needs to be done once and run via Claude Code's scheduled-routines.

## Hosting platform

### ~~Homelab host: RAM bump vs platform refresh~~ — RESOLVED by ADR-012

Resolved by [ADR-012](../docs/decisions.md#adr-012). When the trigger fires (RAM > 85% steady-state on the i5-11400, or a desired service won't fit at the current footprint), the response is to **add** a second mini-PC Proxmox node in an office mini-rack — not refresh or replace the existing host. Paths B (DDR4 bump), C (CPU+board refresh), and D (sell + single mini-PC replacement) are rejected; reasoning is in the ADR. Per-service placement across the two nodes is a follow-on decision deferred until buildout.
