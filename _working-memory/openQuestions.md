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

## Public release

- **When to flip `kendrick/homeops` to public after first scrubbed push?** Options: immediately (after Phase H verification); wait a few days to see if anything rots; wait until WALK phase has substantive content. Default: immediately, since the cleanup discipline is the value.
- **`/schedule` quarterly audit setup.** Interactive setup pending (Claude Code session, `/schedule` skill). Needs to be done once and run via Claude Code's scheduled-routines.
