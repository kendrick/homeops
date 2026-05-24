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

## Hosting platform

### Homelab host: RAM bump vs platform refresh (CRAWL → WALK decision)

**Question:** When 16GB on the i5-11400 / MSI MEG Z490I UNIFY mini-ITX build becomes the bottleneck, what's the right move?

**Current state:**

- 16GB DDR4-3000 in 2x8GB (both slots full; mini-ITX = 2 DIMM slots total)
- LGA 1200 socket = end-of-life Intel (no 12th-gen-or-newer upgrade path on this board)
- Reusable across any refresh: Cooler Master NR200 case, Corsair SF600 PSU, Noctua NH-U9S cooler, WD SN550 1TB NVMe — roughly $400 of components that carry forward

**Paths to weigh when the decision comes due:**

- **A — Stay at 16GB.** $0. Prioritize ruthlessly. CRAWL fits.
- **B — Bump to 64GB DDR4.** ~$500 at mid-2026 pricing (DDR4 supply squeeze; DDR4 production winding down across Samsung / SK Hynix / Micron). Unlocks Immich + Jellyfin + Paperless headroom. Sinks money into legacy memory in a legacy socket.
- **C — Refresh board + CPU + RAM, keep peripherals.** ~$500-700. Modern LGA 1700 or 1851 platform with DDR5 path forward. Reuses ~$400 of existing components. Noctua sends free LGA 1700 mount kits.
- **D — Sell the build, buy a mini-PC.** Beelink SER8 / MINISFORUM UM870 class. ~$500-700 net after selling the old build. Smaller form factor, lower idle power. Loses the case/PSU/cooler reuse value.

**Inputs that would tip the answer:**

- DDR4 pricing trajectory (~$200/64GB in 2022, ~$500 now; could keep climbing as production winds down)
- Mini-PC pricing trajectory (N305 / Ryzen 7 mini-PCs trending down ~10-15%/year)
- Whether the minirack aesthetic from the earlier conversation is still wanted
- Actual HA RAM footprint by then (entity count + add-on growth)
- Which new services the maintainer wants (Jellyfin / Immich / Paperless-ngx)

**Trigger to revisit:**

- When 16GB is genuinely capacity-bound (RAM > 85% steady-state on the host), OR
- When wanting to add a service that won't fit at 16GB, OR
- At the CRAWL → WALK boundary as a routine review

**Current lean:** stay at 16GB through CRAWL. When the trigger fires, Path C is probably the best ROI; Path B is probably the worst. Path D is the form-factor upgrade option if the minirack still appeals.
