# Architecture Decision Records (ADRs)

Document major technical decisions here. This helps future you (and Claude Code) understand _why_ choices were made.

---

## Template

```markdown
## ADR-XXX: [Decision Title]

**Date:** YYYY-MM-DD  
**Status:** Proposed / Accepted / Deprecated / Superseded  
**Deciders:** [Who made this decision]

### Context

[What's the situation? What problem are we solving?]

### Decision

[What did we decide to do?]

### Consequences

**Positive:**

- [Good outcome 1]
- [Good outcome 2]

**Negative:**

- [Trade-off 1]
- [Trade-off 2]

**Neutral:**

- [Neither good nor bad, just different]

### Alternatives Considered

1. **Option A:** [Why we didn't choose this]
2. **Option B:** [Why we didn't choose this]
```

---

---
id: ADR-001
title: Home Assistant as Core Platform
status: accepted
date: 2024-12
decision_question: What platform should be the core smart-home brain that supports self-hosting, privacy, local control, and avoids vendor lock-in?
decision_outcome: Use Home Assistant OS as the core smart home brain.
alternatives_considered:
  - option: SmartThings
    reason_rejected: Cloud-dependent and Samsung could shut down the service at any time.
  - option: Hubitat
    reason_rejected: Local but has a smaller ecosystem and is expensive per hub.
  - option: Custom solution
    reason_rejected: Too much reinventing the wheel for marginal gain.
decision_drivers:
  - Self-hosting and privacy goals
  - Avoidance of vendor lock-in and subscriptions
  - Need for broad integration support and an active community
  - Preference for local control over cloud dependencies
supersedes: null
superseded_by: null
---

## ADR-001: Home Assistant as Core Platform

**Date:** 2024-12  
**Status:** Accepted  
**Deciders:** Kendrick

### Context

Need a smart home platform that supports self-hosting, privacy, local control, and avoids vendor lock-in. Options include SmartThings, Hubitat, Home Assistant, or building custom.

### Decision

Use Home Assistant OS as the core smart home brain.

### Consequences

**Positive:**

- Open source, huge community
- Local control prioritized
- Integrations for everything
- No vendor lock-in or subscription required (except optional Nabu Casa)
- Can self-host all services

**Negative:**

- Steeper learning curve than cloud platforms
- Requires ongoing maintenance
- Breaking changes in updates (mitigated by waiting before updating)

**Neutral:**

- YAML configuration (pro for techies, con for non-technical users)

### Alternatives Considered

1. **SmartThings:** Cloud-dependent, Samsung could shut down service
2. **Hubitat:** Local but smaller ecosystem, expensive per hub
3. **Custom solution:** Too much reinventing the wheel

---

---
id: ADR-002
title: Zigbee as Primary Device Protocol
status: accepted
date: 2024-12
decision_question: Which wireless protocol should be the primary choice for switches, sensors, and other smart-home devices?
decision_outcome: Use Zigbee 3.0 as the primary protocol, falling back to WiFi only where no Zigbee alternative exists.
alternatives_considered:
  - option: Z-Wave
    reason_rejected: Proprietary, requires a separate stick, and has fewer devices available.
  - option: WiFi only
    reason_rejected: Cloud risk, network congestion, and higher power consumption.
  - option: Matter/Thread
    reason_rejected: Ecosystem is too immature with limited devices available today.
decision_drivers:
  - Open standard with no vendor lock-in
  - Local control without cloud dependency
  - Mesh networking extends range across the house
  - Lower power consumption for battery-powered devices
supersedes: null
superseded_by: null
---

## ADR-002: Zigbee as Primary Device Protocol

**Date:** 2024-12  
**Status:** Accepted  
**Deciders:** Kendrick

### Context

Need to choose wireless protocol for switches, sensors, and other devices. Options: Zigbee, Z-Wave, WiFi, Matter, Thread.

### Decision

Use Zigbee 3.0 as primary protocol, with WiFi for devices that don't have Zigbee alternatives.

### Consequences

**Positive:**

- Open standard (not proprietary like Z-Wave)
- Mesh networking (devices extend range)
- Local control, no cloud required
- Wide device selection
- Lower power consumption than WiFi
- Matter-compatible path forward

**Negative:**

- Requires coordinator hardware ($20)
- Interference possible with WiFi on 2.4 GHz
- Some cheap Zigbee devices have poor quality

**Neutral:**

- Different from Z-Wave (can't use Z-Wave devices without separate stick)

### Alternatives Considered

1. **Z-Wave:** Proprietary, requires separate stick, fewer devices
2. **WiFi only:** Cloud risk, network congestion, power hungry
3. **Matter/Thread:** Too immature, limited devices available now

---

---
id: ADR-003
title: Network Segmentation with VLANs
status: accepted
date: 2024-12
decision_question: How should the network be structured to isolate IoT devices from personal devices while still letting Home Assistant control them?
decision_outcome: Implement VLAN segmentation with separate trusted, IoT, guest, and server VLANs, plus firewall rules that allow trusted-to-IoT control but block IoT-to-trusted access.
alternatives_considered:
  - option: Flat network
    reason_rejected: Easy to set up but offers no isolation and is insecure.
  - option: Separate physical networks
    reason_rejected: Expensive and requires duplicate access points throughout the house.
  - option: Firewall only (no VLANs)
    reason_rejected: Provides less granular control than VLAN-based segmentation.
decision_drivers:
  - IoT devices are security risks and must be isolated from personal devices
  - Privacy and security goals of the homeowner
  - Desire to block IoT devices from arbitrary internet access
  - Need to retain visibility into network traffic
supersedes: null
superseded_by: null
---

## ADR-003: Network Segmentation with VLANs

**Date:** 2024-12  
**Status:** Accepted  
**Deciders:** Kendrick

### Context

IoT devices are security risks. Need to isolate smart home devices from personal devices (phones, computers) while allowing HA to control them.

### Decision

Implement VLAN segmentation:

- VLAN 1: Trusted (phones, computers, Apple TVs)
- VLAN 10: IoT (all smart home devices)
- VLAN 20: Guest WiFi
- VLAN 30: Servers (HA, self-hosted services)

Firewall rules allow trusted → IoT control, but IoT cannot reach trusted devices.

### Consequences

**Positive:**

- Compromised IoT device cannot pivot to personal devices
- Better visibility into network traffic
- Can block IoT internet access except firmware updates
- Professional-grade security

**Negative:**

- More complex network setup
- Requires managed switch + router with VLAN support
- Troubleshooting is harder
- Initial configuration time-consuming

**Neutral:**

- Overkill for some, but aligns with homeowner's privacy goals

### Alternatives Considered

1. **Flat network:** Easy but insecure
2. **Separate physical networks:** Expensive, requires duplicate APs
3. **Firewall only (no VLANs):** Less granular control

---

---
id: ADR-004
title: Nabu Casa Cloud for Remote Access
status: accepted
date: 2024-12
decision_question: How should remote access to Home Assistant and Apple Home / Siri integration be provided for the household?
decision_outcome: Subscribe to Nabu Casa Cloud ($6.50/month) for remote access and Apple Home integration.
alternatives_considered:
  - option: Tailscale VPN
    reason_rejected: Free but requires VPN on every device and offers no Siri integration.
  - option: Port forwarding + DuckDNS
    reason_rejected: Risky because it exposes Home Assistant directly to the internet.
  - option: Cloudflare Tunnel
    reason_rejected: More setup overhead and less Home Assistant-specific than Nabu Casa.
decision_drivers:
  - Need for simple, reliable remote access without exposing HA to the internet
  - Existing Apple ecosystem in the household requires Siri integration
  - Encrypted tunnel without manual port forwarding is safer
  - Subscription cost is acceptable and supports HA development
supersedes: null
superseded_by: null
---

## ADR-004: Nabu Casa Cloud for Remote Access

**Date:** 2024-12  
**Status:** Accepted  
**Deciders:** Kendrick

### Context

Need remote access to HA when away from home. Also want Siri integration for the household. Options: Nabu Casa, self-hosted VPN, Tailscale, port forwarding.

### Decision

Subscribe to Nabu Casa Cloud ($6.50/month) for remote access and Apple Home integration.

### Consequences

**Positive:**

- Dead-simple setup (5 minutes)
- Supports Home Assistant development financially
- Siri integration works perfectly
- Encrypted tunnel (secure)
- No port forwarding (safer than exposing HA to internet)
- Includes Alexa/Google Assistant if ever needed

**Negative:**

- Monthly cost ($78/year)
- Technically a cloud dependency (ironic given self-hosting preference)
- If Nabu Casa shuts down, need to reconfigure

**Neutral:**

- Could self-host alternative, but time cost > money cost for this one

### Alternatives Considered

1. **Tailscale VPN:** Free but requires VPN on all devices, no Siri integration
2. **Port forwarding + DuckDNS:** Risky, exposes HA to internet
3. **Cloudflare Tunnel:** More setup, less HA-specific

---

---
id: ADR-005
title: Mix of Inovelli and Shelly Switches
status: accepted
date: 2024-12
decision_question: Which smart switches should be used throughout the house given a ~$1,000 budget and varied room requirements?
decision_outcome: Use Inovelli Blue switches for high-traffic and scene-control areas (15 switches) and Shelly relays for shallow boxes and aesthetic-preserving locations (10 units).
alternatives_considered:
  - option: All Inovelli
    reason_rejected: Over budget at $1,500+ and overkill for low-traffic rooms.
  - option: All Shelly
    reason_rejected: Cheaper but lacks scene control and is WiFi-only.
  - option: Budget brands (Sonoff)
    reason_rejected: Reliability concerns and poor Home Assistant integration.
decision_drivers:
  - $1,000 switch budget must accommodate roughly 25 switches
  - High-traffic rooms benefit from scene control and LED notifications
  - Some boxes are too shallow for Inovelli and require slim relays
  - Preserving existing switch aesthetic matters in certain rooms (HAF)
supersedes: null
superseded_by: null
---

## ADR-005: Mix of Inovelli and Shelly Switches

**Date:** 2024-12  
**Status:** Accepted  
**Deciders:** Kendrick

### Context

Need smart switches throughout house. Budget is ~$1,000 for switches. Options: All Inovelli (expensive but feature-rich), all Shelly (cheap but less features), or mix.

### Decision

Use Inovelli Blue switches for high-traffic / scene-control areas (15 switches). Use Shelly relays for shallow boxes / aesthetic preservation (10 units).

### Consequences

**Positive:**

- Best of both worlds: features where needed, budget-friendly elsewhere
- Shelly preserves existing switch aesthetic (HAF)
- Inovelli scene control reduces need for extra buttons
- Mix still within budget

**Negative:**

- Two different configuration methods
- Inovelli is Zigbee, Shelly is WiFi (mixed protocols)
- Slightly more complex inventory

**Neutral:**

- Total cost ~$975-1,200 (within budget)

### Alternatives Considered

1. **All Inovelli:** Over budget ($1,500+), overkill for some rooms
2. **All Shelly:** Cheaper but no scene control, WiFi only
3. **Budget brands (Sonoff):** Reliability concerns, poor HA integration

---

---
id: ADR-006
title: Resideo Panel as Z-Wave Hub + Wall Interface
status: accepted
date: 2024-12
decision_question: How should the builder-installed Resideo ProSeries panel be used given that professional monitoring is not desired and Home Assistant should remain the brain?
decision_outcome: Use the Resideo panel as a Z-Wave hub, a wall-mounted HomeKit interface for HA, and a local sensor platform via AlarmDecoder, with HA remaining the brain.
alternatives_considered:
  - option: Ignore Resideo
    reason_rejected: Wastes builder-installed equipment with real capabilities.
  - option: Replace with HA-only
    reason_rejected: Loses the touchscreen wall interface and the built-in Z-Wave hub.
  - option: Use Total Connect
    reason_rejected: Introduces cloud dependency and an ongoing monthly fee.
decision_drivers:
  - Builder already installed a capable Resideo ProSeries panel with Z-Wave and HomeKit
  - Desire to avoid monthly monitoring fees and cloud dependencies
  - Value of a wall-mounted touchscreen interface for the household
  - Reuse of the panel's Z-Wave controller avoids buying a separate stick
supersedes: null
superseded_by: null
---

## ADR-006: Resideo Panel as Z-Wave Hub + Wall Interface

**Date:** 2024-12  
**Status:** Accepted  
**Deciders:** Kendrick

### Context

Builder installed Resideo ProSeries panel with Z-Wave and HomeKit support. Don't need professional monitoring, want full HA control.

### Decision

Use Resideo as:

1. **Z-Wave hub** for Z-Wave devices (smoke detectors, etc.)
2. **Wall-mounted interface** for HA via HomeKit Bridge
3. **Sensor platform** integrated to HA via AlarmDecoder (local)

HA remains the brain, Resideo is a peripheral device.

### Consequences

**Positive:**

- Leverage Resideo's Z-Wave controller (don't need separate Z-Wave stick)
- Beautiful wall interface for controlling HA devices (touchscreen)
- Local control via AlarmDecoder (no cloud dependency)
- Pre-wired sensors (if any) integrate to HA
- Panel still functions independently (HAF - manual fallback)
- No monthly fees

**Negative:**

- Need to purchase AlarmDecoder ($80)
- Need to open panel to install AlarmDecoder
- Slightly more complex setup than single platform
- Resideo interface limited to HomeKit capabilities

**Neutral:**

- Z-Wave + Zigbee both in use (but isolated networks)

### Alternatives Considered

1. **Ignore Resideo:** Waste of builder-installed equipment
2. **Replace with HA-only:** Lose touchscreen interface, Z-Wave hub
3. **Use Total Connect:** Cloud dependency, monthly fee

---

---
id: ADR-007
title: Forgejo on a native LXC for self-hosted git
status: accepted
date: 2026-05
decision_question: How should self-hosted git be deployed on the Proxmox homelab — native LXC, Docker compose, or a dedicated VM?
decision_outcome: Run Forgejo as a native binary in an unprivileged Debian LXC on Proxmox (CT 100), backed by SQLite, exposed over Tailscale.
alternatives_considered:
  - option: Gitea
    reason_rejected: Forgejo is a community fork with the same shape and stronger long-term governance; no Gitea-specific feature is needed.
  - option: GitLab CE
    reason_rejected: Heavyweight for a single-user homelab; resource cost outweighs any feature gain.
  - option: Forgejo via Docker Compose (with Postgres)
    reason_rejected: Stacks Docker on top of LXC for no benefit on Proxmox; doubles backup surface (Docker volumes + LXC snapshots); pushes the project into the privileged-LXC + Docker-in-LXC pattern unnecessarily.
  - option: Dedicated VM for Forgejo
    reason_rejected: VM overhead is wasted; LXC + native binary is lighter and snapshots/backups work identically.
decision_drivers:
  - Proxmox already provides container lifecycle, snapshots, vzdump backups — avoid layering Docker on top
  - Single-user homelab; SQLite is sufficient and removes Postgres operational burden
  - Tailscale-only exposure means no public ingress needed
  - Smaller blast radius if compromised (unprivileged LXC + no Docker)
supersedes: null
superseded_by: null
---

## ADR-007: Forgejo on a native LXC for self-hosted git

**Date:** 2026-05
**Status:** Accepted
**Deciders:** Kendrick

### Context

Self-hosting git for the homeops project and future personal repos was on the Crawl-phase backlog. The Proxmox host (i5-11400, 16GB) is already up running the HA OS VM with headroom to spare, and off-network access is wanted without standing up public ingress. The decision was which deployment shape git should take — native LXC, Docker in an LXC, or a dedicated VM.

### Decision

Use the community Proxmox helper script to land an unprivileged Debian LXC (CT 100) and install Forgejo as a systemd-managed binary against SQLite. The service listens on port 3000 inside the tailnet only — no public ingress, no reverse proxy. Backups ride along with Proxmox `vzdump` on the LXC, so the host-level backup story already covers it.

### Consequences

**Positive:**

- Lightweight: a single native process per LXC, no Docker or Postgres to babysit
- Snapshots-as-backups via Proxmox `vzdump` cover both data and config
- Unprivileged LXC + no Docker keeps the security posture clean
- Upgrade path is just `apt` + a Forgejo binary swap

**Negative:**

- SQLite is single-process — fine for solo use, would need a Postgres migration before going multi-user
- Web UI is barer than GitLab (acceptable for the workflow)

**Neutral:**

- Locks the project into the Proxmox helper-script ecosystem for now (low-risk, easy to walk back if needed)

### Alternatives Considered

1. **Gitea:** Same shape as Forgejo, but Forgejo's community fork has stronger long-term governance and there's no Gitea-specific feature needed here.
2. **GitLab CE:** Heavyweight for a single-user homelab; the resource cost outweighs any feature gain.
3. **Forgejo via Docker Compose (with Postgres):** Stacks Docker on top of LXC for no benefit on Proxmox, doubles the backup surface, and pushes the project into the Docker-in-LXC pattern unnecessarily.
4. **Dedicated VM for Forgejo:** VM overhead is wasted — LXC + native binary is lighter and snapshots/backups work identically.

---

---
id: ADR-008
title: Tailscale for off-network access to the homelab
status: accepted
date: 2026-05
decision_question: How should the homelab (Forgejo, Claude Code dev LXC, future services) be reachable from off-network without exposing public ingress?
decision_outcome: Install Tailscale on each LXC that needs external reachability; route via the Tailscale mesh.
alternatives_considered:
  - option: Port forwarding + dynamic DNS
    reason_rejected: Exposes services to the public internet; demands TLS termination + auth at every service; one misconfiguration leaks the homelab.
  - option: Self-hosted WireGuard
    reason_rejected: Functional but adds an operational burden — key rotation, NAT traversal, mobile-client UX. Tailscale solves these for free at this scale.
  - option: Cloudflare Tunnel
    reason_rejected: Routes traffic through Cloudflare; mismatches the self-hosting + privacy posture of the broader project.
decision_drivers:
  - Zero public ingress required (smaller attack surface)
  - Free tier is sufficient (≤3 users, ≤100 devices)
  - Cross-OS clients with workable UX (macOS, iOS, Linux)
  - Subnet routing available as a future upgrade if more LAN reach is wanted
supersedes: null
superseded_by: null
---

## ADR-008: Tailscale for off-network access to the homelab

**Date:** 2026-05
**Status:** Accepted
**Deciders:** Kendrick

### Context

Off-network access is needed to Forgejo (ADR-007), the Claude Code dev LXC (ADR-010), and likely other future homelab services. The hard constraint is zero public ingress — port-forwarding the homelab to the internet is off the table. The decision was how to provide secure remote reach without standing up a public attack surface.

### Decision

Install Tailscale on each LXC that needs to be reachable from off-network. Start with a per-host install (Forgejo, dev LXC); defer the subnet-router pattern as a Walk-phase consideration if/when more of the LAN needs to be reachable. Clients install on the maintainer's macOS laptop and iOS phone.

### Consequences

**Positive:**

- Zero public ingress; the attack surface is the Tailscale client itself
- Free tier (≤3 users, ≤100 devices) is plenty for a single-user homelab
- Cross-OS client UX (macOS, iOS, Linux) just works
- Subnet routing remains available as an upgrade path

**Negative:**

- Tailscale account ties the homelab to a real identity / control-plane account — captured as an open question; acceptable trade-off for now
- Adds a soft cloud dependency (the coordination server), though the data plane stays peer-to-peer

**Neutral:**

- Mesh VPN is a new operational concept to maintain, but the per-host install model keeps it minimal

### Alternatives Considered

1. **Port forwarding + dynamic DNS:** Exposes services publicly, demands TLS + auth at every service, and one misconfiguration leaks the homelab.
2. **Self-hosted WireGuard:** Functional but adds the burden of key rotation, NAT traversal, and mobile-client UX. Tailscale solves these for free at this scale.
3. **Cloudflare Tunnel:** Routes homelab traffic through Cloudflare, which mismatches the self-hosting and privacy posture of the broader project.

---

---
id: ADR-009
title: Native LXC over Docker for homelab services on Proxmox
status: accepted
date: 2026-05
decision_question: What's the default deployment unit for self-hosted services on a Proxmox homelab — native LXC, Docker in LXC, or a dedicated Docker VM?
decision_outcome: Default to one native unprivileged LXC per service; reach for Docker only when an app ships compose-only and porting is genuinely impractical.
alternatives_considered:
  - option: Docker in a privileged LXC (one shared LXC running many compose stacks)
    reason_rejected: Punches through unprivileged-LXC isolation as a default; stacks abstractions Proxmox already provides (snapshots, backups, lifecycle, web UI); larger blast radius if any one service is compromised.
  - option: Dedicated Docker VM
    reason_rejected: VM overhead + duplicates Proxmox's container management; introduces a Docker-only operational pattern when most services have clean native package paths.
  - option: Mix freely from the start
    reason_rejected: Operational inconsistency; doubles the runbook surface; encourages "Docker by default" tutorial-following without justification.
decision_drivers:
  - Proxmox primitives (LXC, snapshots, vzdump, web UI) already cover the container-lifecycle needs that Docker would provide
  - Smaller, isolatable blast radius per service
  - Lower abstraction count = fewer places to debug at 11pm
  - Docker-when-necessary policy preserves an escape hatch for compose-only apps
supersedes: null
superseded_by: null
---

## ADR-009: Native LXC over Docker for homelab services on Proxmox

**Date:** 2026-05
**Status:** Accepted
**Deciders:** Kendrick

### Context

Earlier informal planning had implicitly assumed Docker would be the homelab foundation — the "spin up a compose stack" muscle memory from prior projects. Once the host was Proxmox VE, that assumption needed re-examining: Proxmox already provides container lifecycle, snapshots, `vzdump` backups, and a web UI, and most candidate services have clean native packages. A default deployment shape needed to be picked so per-service decisions don't devolve into Docker-by-default tutorial-following.

### Decision

Default to one native unprivileged LXC per service. Reach for Docker only when an app ships compose-only and porting to a native install is genuinely impractical, and even then, treat it as an exception that gets documented per-service. ADR-007 (Forgejo as a native LXC) and ADR-010 (Claude Code as a dedicated dev LXC) are the first two instances of this policy.

### Consequences

**Positive:**

- Proxmox-native operations (snapshots, `vzdump`, web UI) cover container lifecycle without a second abstraction layer
- Smaller, isolatable blast radius per service (one LXC compromised ≠ all services compromised)
- Lower abstraction count = fewer places to debug at 11pm
- Docker-when-necessary policy preserves an escape hatch for compose-only apps

**Negative:**

- Some upstream projects only ship compose files; porting takes effort or forces the exception path
- Slightly more LXCs to manage over time vs. one shared Docker host

**Neutral:**

- This decision overrides the earlier implicit "Docker by default" assumption; existing planning docs that lean Docker-first should be re-read through this lens

### Alternatives Considered

1. **Docker in a privileged LXC (one shared LXC running many compose stacks):** Punches through unprivileged-LXC isolation as a default, stacks abstractions Proxmox already provides, and gives every service a larger blast radius if any one is compromised.
2. **Dedicated Docker VM:** VM overhead plus duplication of Proxmox's container management; pushes a Docker-only operational pattern when most services have clean native package paths.
3. **Mix freely from the start:** Operational inconsistency, double the runbook surface, and encourages "Docker by default" tutorial-following without justification.

---

---
id: ADR-010
title: Claude Code on a dedicated dev LXC
status: accepted
date: 2026-05
decision_question: Where should Claude Code run when off-laptop work is wanted — on the Forgejo LXC, on a dedicated dev LXC, or on a Docker container?
decision_outcome: Run Claude Code (Node CLI under tmux) in a dedicated unprivileged Debian LXC (CT 101), on the tailnet, separate from Forgejo.
alternatives_considered:
  - option: Co-tenant Claude Code on the Forgejo LXC (CT 100)
    reason_rejected: Mixes long-running agent permissions with the git-data store; bad blast radius if the agent goes sideways; couples two unrelated lifecycles.
  - option: Laptop-only (no off-laptop install)
    reason_rejected: Long-running agents tie up the laptop; loses /loop and background-agent value when the laptop sleeps.
  - option: Docker container on a Docker LXC
    reason_rejected: Inconsistent with ADR-009 (native LXC over Docker for homelab services); adds an unnecessary abstraction.
decision_drivers:
  - Clean separation of concerns (git host vs dev agent vs HA)
  - Consistent with ADR-009 (native LXC default)
  - tmux-survivable SSH sessions over Tailscale make off-laptop work realistic
  - Cheap to spin up an additional LXC on this host
supersedes: null
superseded_by: null
---

## ADR-010: Claude Code on a dedicated dev LXC

**Date:** 2026-05
**Status:** Accepted
**Deciders:** Kendrick

### Context

Claude Code is wanted off-laptop so long-running agent sessions (`/loop`, background work) survive a closed lid and so the laptop isn't tethered to a running agent. The homelab already has a Proxmox host with the Forgejo LXC (ADR-007) on the tailnet (ADR-008). The decision was where the Claude Code runtime should live — co-tenant with Forgejo, in its own LXC, or via Docker.

### Decision

Run Claude Code in a dedicated unprivileged Debian LXC (CT 101) — Node CLI under tmux, on the tailnet, fully separate from the Forgejo LXC. SSH in over Tailscale, attach to tmux, work, detach. This is the second instance of the ADR-009 native-LXC-default policy.

### Consequences

**Positive:**

- Clean separation of concerns: git host (CT 100), dev agent (CT 101), HA OS VM each have independent lifecycles and blast radii
- Consistent with ADR-009 — no Docker layer to manage
- tmux-survivable SSH-over-Tailscale makes off-laptop work feel native
- Easy to snapshot/rebuild the dev LXC without touching anything else

**Negative:**

- One more LXC to maintain (small cost on this host)
- Off-laptop development depends on the homelab being up + the tailnet being healthy

**Neutral:**

- Some context-switching cost going from laptop-local to LXC-remote, though tmux + persistent SSH minimize it

### Alternatives Considered

1. **Co-tenant Claude Code on the Forgejo LXC (CT 100):** Mixes long-running agent permissions with the git-data store, creates a bad blast radius if the agent goes sideways, and couples two unrelated lifecycles.
2. **Laptop-only (no off-laptop install):** Long-running agents tie up the laptop and lose `/loop` and background-agent value the moment the laptop sleeps.
3. **Docker container on a Docker LXC:** Inconsistent with ADR-009 (native LXC over Docker) and adds an unnecessary abstraction for a single-process Node CLI.

```

---

## **Your Setup Will Look Like:**
```

Home Assistant Server (Office)
├── Sonoff Zigbee Coordinator → Zigbee devices (switches, sensors)
├── AlarmDecoder → Resideo Panel
│ ├── Z-Wave devices (smoke detectors, etc.)
│ ├── Wired sensors (doors, windows, motion)
│ └── Touchscreen (controls HA via HomeKit)
└── Nabu Casa → Apple Home (phones, HomePods, Resideo panel)

---

## Future ADRs

Document new decisions as you make them:

- ADR-006: Kwikset vs Schlage locks
- ADR-007: IKEA vs Lutron smart blinds
- ADR-008: Energy monitoring solution
- ADR-009: Smoke detector integration approach
- ADR-010: Garage opener replacement choice

---

**Keep this updated! It's invaluable for explaining your reasoning to future you or anyone who takes over.**
