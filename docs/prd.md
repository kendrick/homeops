# Product Requirements Document {#prd}

## The Smart Home Project {#overview}

**Last updated:** December 2024
**Project duration:** 18 months
**Status:** Pre-launch (planning phase)

---

## Executive Summary {#executive-summary}

Transform a new-build home into a sophisticated, self-hosted smart home using Home Assistant as the core platform with Apple Home as the household interface. Prioritize reliability, privacy, and user experience while satisfying the homeowner's desire to self-host and tinker.

**Core thesis:** A smart home should enhance daily life without getting in the way, respect privacy, maintain manual control, and be maintainable by the homeowner without vendor dependency.

---

## Problem Statement {#problem-statement}

### Current Pain Points {#pain-points}

1. **Lighting chaos:** Lights get left on in unoccupied rooms (especially upstairs); no clear map of switches to fixtures; no mood lighting capability
2. **No automation:** Everything is manual, missing opportunities for convenience and energy savings
3. **Future-proofing:** Want foundation that supports expansion without vendor lock-in
4. **Privacy concerns:** Cloud-dependent solutions expose household data

### Success Criteria {#success-criteria}

- Household members use and trust the system (HAF = Household Acceptance Factor)
- Daily behaviors improve through gentle automation (lights off when leaving, etc.)
- Guests can intuitively control basics without help
- System runs reliably with <1 hour maintenance per month
- No regrettable vendor choices that limit future expansion

---

## User Personas {#personas}

### Primary User: Maintainer (Homeowner) {#persona-maintainer}

- **Role:** System architect, implementer, maintainer
- **Technical level:** High (CLI comfortable, dev background, UX professional)
- **Motivation:** Love of tinkering, self-hosting ethos, privacy concerns
- **Constraints:** Limited time, budget-conscious
- **Goals:** Build reliable system, learn new tech, avoid vendor lock-in

### Secondary Users: Household Members {#persona-household}

- **Role:** Daily users, acceptability gatekeepers
- **Technical level:** Varied — assume low for design purposes
- **Motivation:** Convenience, not complexity
- **Constraints:** Low tolerance for broken features
- **Goals:** Simple voice/app control, reliable basics, doesn't want to think about it

Design for the lowest-comfort household member. If a feature requires reading docs to use, it has failed.

### Tertiary Users: Guests {#persona-guests}

- **Role:** Infrequent visitors
- **Technical level:** Unknown (assume low)
- **Motivation:** Basic comfort (lights, temperature, music)
- **Constraints:** Zero training, no apps installed
- **Goals:** Intuit how to turn on lights, adjust temperature, play music

---

## Core Principles {#principles}

### Non-Negotiables {#non-negotiables}

1. **Home Assistant is the brain** - All logic runs through HA
2. **Manual overrides always work** - Physical switches must function even if HA is down
3. **Privacy-first architecture** - Network segmentation, local control prioritized
4. **Self-hosted > cloud** - Avoid subscriptions and data sharing
5. **Open protocols** - Zigbee, Matter, open APIs (no proprietary lock-in)

### Strong Preferences {#strong-preferences}

- Apple Home as household interface (existing ecosystem)
- Zigbee for device connectivity (mature, local, meshes well)
- Incremental rollout over big-bang deployment
- Documentation as you build (future you will thank you)
- Community-supported solutions (avoid obscure integrations)

### Acceptable Compromises {#acceptable-compromises}

- Nabu Casa subscription ($6.50/month) for remote access + Siri integration
- Some WiFi devices in isolated VLAN if Zigbee alternative unavailable
- Cloud integrations for weather data, notifications (non-critical paths)

---

## Technical Architecture {#architecture}

### Platform Stack {#platform-stack}

```
┌─────────────────────────────────────────────┐
│        Household Interface Layer            │
│  Apple Home • Siri • Wall Tablets • HA App  │
└─────────────────────────────────────────────┘
                     ↕
┌─────────────────────────────────────────────┐
│      Home Assistant (Core Platform)         │
│   Automations • Scenes • Integrations       │
│         Running in Proxmox VM               │
└─────────────────────────────────────────────┘
                     ↕
┌─────────────────────────────────────────────┐
│          Device Layer (IoT VLAN)            │
│  Zigbee • WiFi • Z-Wave • IR • Hardwired    │
└─────────────────────────────────────────────┘
```

**Homelab Architecture:**

```
Repurposed Office PC
   └── Proxmox VE (Hypervisor)
        ├── VM: Home Assistant OS
        │    ├── 2-4 vCPU
        │    ├── 4-8GB RAM
        │    ├── 32GB storage
        │    └── USB passthrough (Zigbee coordinator)
        │
        └── VM: Homelab Services
             ├── Docker containers
             ├── Self-hosted apps
             └── Future expansion
```

**Why Proxmox for HA:**
- **VM snapshots** before major updates (instant rollback)
- **Resource isolation** prevents other services from affecting HA
- **USB passthrough** for Zigbee coordinator
- **Backup flexibility** (VM-level + HA built-in backups)
- **Future-proof** for adding services without touching HA

**Installation approach:** Install Proxmox on bare metal, then deploy HA OS as a VM using the official Proxmox integration. Other homelab services run in separate VM(s) for complete isolation.

### Network Architecture {#network-architecture}

```
Internet
   ↓
Firewall/Router
   ├── VLAN 1 (Default): Phones, laptops, Apple TVs
   ├── VLAN 10 (IoT): All smart home devices
   ├── VLAN 20 (Guest): Guest WiFi
   └── VLAN 30 (Servers): HA + self-hosted services

Rules:
• VLAN 1 → can reach 10, 30 (users control devices)
• VLAN 10 → can reach 30 (devices talk to HA)
• VLAN 10 → CANNOT reach 1 (compromised device can't pivot)
• VLAN 10 → Internet blocked except firmware updates
```

**VLAN Assignment Quick Reference:**

| Device Type | VLAN | IP Range | Notes |
|-------------|------|----------|-------|
| Phones, laptops, Apple TVs | 1 | 192.168.1.x | Trusted devices |
| Zigbee coordinator | 30 | 192.168.30.x | USB attached to HA server |
| WiFi smart devices | 10 | 192.168.10.x | Isolated, limited internet |
| HA server | 30 | 192.168.30.x | Static IP recommended |
| Guest devices | 20 | 192.168.20.x | No access to other VLANs |

### Device Protocols Decision Matrix {#protocols}

| Protocol      | Use Case                 | Pros                | Cons                  | Deployment     |
| ------------- | ------------------------ | ------------------- | --------------------- | -------------- |
| **Zigbee**    | Switches, sensors, locks | Local, mesh, mature | Coordinator required  | Primary        |
| **WiFi**      | Relays, cameras, TVs     | Ubiquitous, fast    | Cloud risk, bandwidth | VLAN isolated  |
| **Matter**    | Future devices           | Standard, interop   | Immature ecosystem    | Wait & see     |
| **Z-Wave**    | Smoke detectors          | Reliable, secure    | Coordinator needed    | Limited use    |
| **Hardwired** | Thermostats, garage      | Most reliable       | Installation effort   | Where possible |

**When to Use Which Protocol:**

Use **Zigbee** when:
- Device is a switch, sensor, or lock
- Local control is required (no cloud dependency)
- Mesh networking benefits the location (extends range)
- Low power consumption matters (battery devices)

Use **WiFi** when:
- No Zigbee alternative exists (e.g., Rachio, some thermostats)
- Device is already owned and WiFi-only
- High bandwidth needed (cameras, streaming)
- Specific feature requires WiFi (e.g., Kwikset fingerprint firmware updates)

Use **Z-Wave** when:
- Zigbee interference is an issue
- Device is safety-critical (smoke detectors)
- Already invested in Z-Wave ecosystem

**Exception handling:** If you must use a cloud-dependent WiFi device, document WHY in `integrations/` folder and add to VLAN 10 with firewall rules limiting its internet access to required endpoints only.

### Switch Selection Decision Tree {#switch-selection}

**Choose Inovelli Blue when:**
- [ ] Room is high-traffic (family room, kitchen, hallways)
- [ ] Need scene control (double-tap, hold, etc.)
- [ ] Want RGB LED notifications (visual feedback)
- [ ] 3-way or 4-way switch configuration
- [ ] Standard switch box depth (≥2.5")

**Choose Shelly relay when:**
- [ ] Shallow switch box (Inovelli won't fit - <2.5" depth)
- [ ] Want to preserve existing switch aesthetic
- [ ] Budget-constrained room (guest room, closets)
- [ ] Single-pole switch only (simpler wiring)
- [ ] WiFi-only location with poor Zigbee coverage

**When in doubt:** Default to Inovelli Blue. The scene control and LED features justify the cost in most rooms.

---

## Project Phases {#phases}

### Phase 1: CRAWL (Months 0-3) {#phase-crawl}

**Theme:** Fix annoyances, build foundation

**Budget:** $1,500-2,500

**Key Deliverables:**

- [ ] Proxmox VE installed on repurposed office PC
- [ ] Home Assistant OS running in Proxmox VM
- [ ] Zigbee coordinator USB passthrough configured
- [ ] Network VLANs configured and tested
- [ ] Zigbee coordinator installed (Sonoff ZBDongle-E)
- [ ] 20-25 smart switches deployed (Inovelli + Shelly)
- [ ] All switches labeled (know what controls what)
- [ ] Smart locks on front/back doors (Kwikset Halo)
- [ ] Phone-based presence detection
- [ ] Core automations (leaving, bedtime, evening mode)
- [ ] Apple Home integration working
- [ ] Backup strategy implemented (VM snapshots + HA backups)

**Success Metrics:**

- Zero "lights left on in empty rooms" incidents in final 2 weeks
- Household members successfully use 3+ scenes via Siri
- HA uptime >99%
- All manual overrides tested and working

**Detailed checklist:** See `phases/crawl.md`

---

### Phase 2: WALK (Months 3-9) {#phase-walk}

**Theme:** Expand sensing, add convenience

**Budget:** ~$1,000

**Key Deliverables:**

- [ ] Door/window sensors (8-12 strategic placements)
- [ ] Water leak sensors (14 locations: toilets, sinks, appliances)
- [ ] Motion sensors (5-6 key areas)
- [ ] Thermostat integration (Honeywell T6 Pro)
- [ ] Garage mini-split climate control
- [ ] Rachio 3 sprinkler integration (drip zones for trees + garden)
- [ ] Apple TV scene automations
- [ ] Sonos integration (as speakers acquired)
- [ ] Notification system (push, TTS, visual)
- [ ] Circadian lighting (adaptive color temp)

**Success Metrics:**

- Zero false positive leak alerts
- Rachio skips watering due to rain 3+ times
- Notification latency <30 seconds for critical events
- Household uses Apple TV automations regularly
- No complaints about automation "getting in the way"

**Detailed checklist:** See `phases/walk.md`

---

### Phase 3: RUN (Months 9-18) {#phase-run}

**Theme:** Perfect the experience

**Budget:** $2,000-5,000 (flexible)

**Key Deliverables:**

- [ ] mmWave presence sensors (4-6 rooms for stationary detection)
- [ ] Smart window coverings (6 problem windows)
- [ ] Whole-home energy monitoring (Emporia Vue 2)
- [ ] HomePod minis (4 locations for voice control)
- [ ] Smoke/CO detector integration
- [ ] Garage opener replacement + automation (Genie)
- [ ] Wall-mounted tablets (3× Fire HD 8)
- [ ] Guest-friendly dashboards
- [ ] Discord bot for remote control
- [ ] Complete household documentation
- [ ] Advanced scene management

**Success Metrics:**

- Guests control lights/music without help
- Energy monitoring reveals 10%+ savings
- Presence detection accuracy >95%
- Zero "broken" incidents in final month
- Household members suggest new automation ideas

**Detailed checklist:** See `phases/run.md`

---

## Device Inventory {#inventory}

### Current State {#current-devices}

**Already owned:**

- Eufy S1 Pro robot vac/mop
- Rachio 3 sprinkler controller (not installed)
- Sonos Move speaker
- Honeywell T6 Pro thermostats (2)
- Kwikset locks/handles (SmartKey compatible)
- LiftMaster garage opener (Security+ 3)
- 4× 4K TVs + Apple TVs

**Planned Purchases:**
See `inventory.md` for complete tracking (update as you buy!)

---

## Integration Strategy {#integration-strategy}

### High Priority (Crawl) {#integrations-crawl}

- **Zigbee devices** via ZHA integration
- **Apple Home** via Nabu Casa or HomeKit Bridge
- **Nabu Casa Cloud** for remote access + Siri
- **Mobile app** (HA Companion) for presence + notifications

### Medium Priority (Walk) {#integrations-walk}

- **Rachio** via official integration (excellent)
- **Apple TV** via built-in integration
- **Sonos** via official integration (cloud but reliable)
- **Honeywell thermostats** via Honeywell Home integration
- **Broadlink** for IR control (garage mini-split)

### Lower Priority (Run) {#integrations-run}

- **Energy monitoring** (Emporia Vue 2)
- **Discord bot** via webhooks or AppDaemon
- **Smoke/CO detectors** (Z-Wave or listener devices)
- **mmWave sensors** (various manufacturers)

### Integration Health Checklist {#integration-health}

For each integration, verify before deploying:

- [ ] Local control available (or acceptable reason for cloud)
- [ ] HA community support strong (check forums, GitHub issues)
- [ ] Breaking changes infrequent (check changelog history)
- [ ] Documentation clear and updated
- [ ] Fallback plan if integration breaks

**Integration Evaluation Template:**

```markdown
## Integration: [Name]

**Local control:** Yes/No (if No, why acceptable: ___)
**Community support:** Strong/Medium/Weak (link to forum thread: ___)
**Last breaking change:** [date] (acceptable if >6 months ago)
**Fallback plan:** [what happens if this breaks]
**Tested on HA version:** [version]
```

---

## Automation Philosophy {#automation-philosophy}

### Categories {#automation-categories}

**Time-based automations:**

- Morning routine (lights, temperature)
- Evening mode (lighting color temp)
- Bedtime sequence (dim, lock, secure)

**Event-based automations:**

- Motion → lights (context-aware: time of day, occupancy)
- Door unlock → entry lights
- Leaving home → secure house
- Arriving home → welcome sequence

**Condition-based automations:**

- If temp >X → close blinds
- If everyone gone → away mode
- If raining → skip watering

**Continuous automations:**

- Circadian lighting (color temp tracks sun)
- Presence tracking (room occupancy)
- Energy optimization (shift loads to off-peak)

### Design Patterns {#automation-patterns}

**Good automation:**

- Solves specific pain point
- Respects manual overrides
- Fails gracefully (safe defaults)
- Provides feedback (notifications, LED indicators)
- Easy to disable/override

**Bad automation:**

- "Clever" but brittle
- Assumes too much (false positives)
- No manual override path
- Silent failures
- Over-complicated logic

### Automation Template {#automation-template}

Use this pattern for ALL automations:

```yaml
# File: automations/{category}_{room}_{action}.yaml
# Example: time_upstairs_bedtime_dim.yaml

alias: "{Category} - {Room} - {Action}"
description: >
  WHAT: Brief description of what this automation does
  WHY: The problem it solves or value it provides
  OVERRIDE: How to manually override if needed

trigger:
  - platform: [state/time/event]
    # trigger configuration

condition:
  - condition: [template/state/time]
    # ALWAYS add conditions to prevent unwanted triggers
    # Example: Only run if someone is home

action:
  - service: [light/switch/notify]
    # action configuration

mode: single  # or restart, queued, parallel - document why

# Required metadata
id: unique_automation_id
```

**Naming Convention:**
- File: `{category}_{room}_{action}.yaml`
- Alias: `{Category} - {Room} - {Action}`
- Categories: `time`, `event`, `presence`, `scene`, `security`
- Examples:
  - `time_upstairs_bedtime_dim.yaml` → "Time - Upstairs - Bedtime Dim"
  - `presence_everyone_leaving_secure.yaml` → "Presence - Everyone - Leaving Secure"
  - `event_front_door_unlock_lights.yaml` → "Event - Front Door - Unlock Lights"

### Testing Protocol {#automation-testing}

1. **Write automation in test mode** (actions → notifications only)
2. **Monitor for 24-48 hours** (does it trigger correctly?)
3. **Enable actions with undo path** (can you reverse it?)
4. **Monitor for 1 week** (any false positives?)
5. **Document and deploy** (add to permanent automations)

**Test Mode Template:**

```yaml
# Testing: Replace actions with notifications
action:
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: >
        TEST: Would have executed [action] because [trigger]
        Conditions: [list conditions that were true]
```

---

## Privacy & Security {#security}

### Threat Model {#threat-model}

**What we're protecting:**

- Household location/presence data
- Daily routines and schedules
- Video/audio from future cameras
- Network access to internal devices

**Who we're protecting against:**

- IoT device manufacturers (data harvesting)
- Compromised smart devices (lateral movement)
- External attackers (internet-facing services)
- Curious neighbors/guests (local network access)

**What we're NOT worried about:**

- Nation-state actors
- Physical device compromise (house security)
- Social engineering (user education is separate)

### Security Measures {#security-measures}

**Network layer:**

- VLAN segmentation (IoT cannot reach personal devices)
- Firewall rules (whitelist approach for IoT internet access)
- Strong WiFi passwords (WPA3 where possible)
- Guest network isolation

**Application layer:**

- HA authentication required (no public access)
- Remote access via Nabu Casa (encrypted tunnel) or VPN
- Regular HA backups (encrypted, offsite)
- HTTPS for all web interfaces

**Device layer:**

- Prefer local protocols (Zigbee > cloud WiFi)
- Change default passwords on all devices
- Disable unused features (cloud connections, UPnP)
- Regular firmware updates (but delay 1 week for bug reports)

### Network Segmentation: Common Mistakes {#network-mistakes}

❌ **Mistake:** Putting HA server on IoT VLAN (VLAN 10)
✅ **Correct:** HA server on Server VLAN (VLAN 30)
**Why:** HA needs to control IoT devices AND be accessible from trusted devices on VLAN 1

❌ **Mistake:** Blocking ALL IoT internet access
✅ **Correct:** Whitelist firmware update domains per device
**Why:** Devices need security updates; document allowed domains in firewall rules

❌ **Mistake:** Putting Apple TVs on IoT VLAN
✅ **Correct:** Apple TVs on Default VLAN (VLAN 1)
**Why:** Apple TVs need to communicate with phones for AirPlay/HomeKit

---

## Budget & Timeline {#budget}

### Financial Overview {#financial-overview}

| Phase     | Duration      | Budget           | Key Expenses                  |
| --------- | ------------- | ---------------- | ----------------------------- |
| Crawl     | 0-3 months    | $1,500-2,500     | Switches, locks, network gear |
| Walk      | 3-9 months    | ~$1,000          | Sensors, climate integration  |
| Run       | 9-18 months   | $2,000-5,000     | Blinds, energy monitoring, UI |
| **Total** | **18 months** | **$4,500-8,500** | Excluding Sonos (separate)    |

### Ongoing Costs {#ongoing-costs}

- Nabu Casa: $6.50/month ($78/year)
- Electricity for HA server: ~$5-10/month
- **Total annual:** ~$140/year

### Cost Optimization Strategies {#cost-optimization}

- Buy during sales (Prime Day, Black Friday)
- Start with essential rooms, expand gradually
- Mix premium (Inovelli) with budget (Shelly) devices
- DIY installation (save $50-100 per device)
- Leverage existing hardware (Rachio, thermostats)

---

## Risk Management {#risk-management}

### Technical Risks {#technical-risks}

| Risk                     | Impact | Likelihood | Mitigation                                        |
| ------------------------ | ------ | ---------- | ------------------------------------------------- |
| HA server failure        | High   | Low        | Daily backups, spare hardware ready               |
| Integration breaks       | Medium | Medium     | Delay updates, test on separate instance          |
| Network misconfiguration | High   | Low        | Document thoroughly, test incrementally           |
| Device incompatibility   | Medium | Low        | Research before buying, keep receipts             |
| Zigbee mesh issues       | Medium | Medium     | Strategic router placement, powered devices first |

### Social Risks {#social-risks}

| Risk                       | Impact | Likelihood | Mitigation                                              |
| -------------------------- | ------ | ---------- | ------------------------------------------------------- |
| Household frustration      | High   | Medium     | Manual overrides, thorough testing, clear communication |
| Users circumventing        | Low    | Medium     | Involve them early, make it fun                         |
| Guest confusion            | Low    | High       | Intuitive controls, clear labels, backup manual         |
| Over-automation creepiness | Medium | Low        | Get buy-in before deploying, privacy-first              |

### Financial Risks {#financial-risks}

| Risk                   | Impact | Likelihood | Mitigation                             |
| ---------------------- | ------ | ---------- | -------------------------------------- |
| Budget overrun         | Medium | Medium     | Phased approach, prioritize ruthlessly |
| Vendor discontinuation | Low    | Low        | Open protocols, avoid cloud-only       |
| Device failures        | Low    | Medium     | Extended warranties, keep spares       |

---

## Success Metrics {#success-metrics}

### Quantitative Metrics {#quantitative-metrics}

**Crawl phase:**

- HA uptime: >99%
- Automation success rate: >95%
- Manual override success: 100%
- Household satisfaction score: ≥8/10

**Walk phase:**

- Sensor response time: <2 seconds
- Notification latency: <30 seconds
- False positive rate: <5%
- Household engagement: 3+ daily interactions

**Run phase:**

- Presence detection accuracy: >95%
- Energy savings: 10%+ vs baseline
- Guest satisfaction: Can control basics without help
- System stability: <1 hour/month maintenance

### Qualitative Metrics {#qualitative-metrics}

**User satisfaction:**

- Household members voluntarily suggest automations
- Household uses voice control regularly
- Guests compliment the setup
- No "I wish we hadn't done this" moments

**Technical quality:**

- Config is maintainable (future you understands it)
- Automations are modular (easy to modify)
- Documentation is complete (someone else could take over)
- No regrettable technology choices

---

## Documentation Standards {#documentation}

### What to Document {#what-to-document}

**Required:**

- Device inventory (make, model, purchase date, location)
- Network topology (VLANs, firewall rules, IP assignments)
- Architecture decisions (ADRs for major choices)
- Automation logic (why, not just what)
- Troubleshooting guides (common issues + fixes)

**Recommended:**

- Household user guides (how to use Apple Home, voice commands)
- Integration notes (quirks, workarounds, version compatibility)
- Maintenance schedules (backup checks, update testing)
- Lessons learned (what worked, what didn't)

### Where to Document {#where-to-document}

**Technical docs:** In repo (`/docs` folder)
**Household guides:** Printed + kitchen tablet
**Quick reference:** Labels on switches, printed cards
**Troubleshooting:** HA companion app bookmarks

### Entity Naming Convention {#entity-naming}

Use consistent naming across all entities:

**Pattern:** `{domain}.{floor}_{room}_{device}_{detail}`

**Examples:**
- `light.first_kitchen_island` (first floor, kitchen, island light)
- `light.second_bedroom_2_ceiling` (second floor, bedroom 2, ceiling light)
- `switch.first_garage_opener` (first floor, garage, opener switch)
- `sensor.second_bath_1_leak` (second floor, bathroom 1, leak sensor)
- `lock.first_front_door` (first floor, front door lock)

**Floor prefixes:**
- `first_` = First floor
- `second_` = Second floor
- `garage_` = Garage (ground level but separate)
- `outdoor_` = Exterior

**Room abbreviations (when needed for length):**
- `br` = Bedroom
- `bath` = Bathroom
- `lr` = Living room
- `fr` = Family room
- `kit` = Kitchen

---

## State Tracking & Context Handoff {#state-tracking}

### How to Know Where You Are {#project-state}

When resuming work or assisting mid-project, check these markers:

1. **`inventory.md`** - What devices are installed?
2. **Phase checklists** - Which items are checked off?
3. **HA Integrations page** - What's configured in HA?
4. **Git tags** - What milestones are complete?
5. **`lessons-learned.md`** - What issues were encountered?

### Phase Completion Markers {#phase-markers}

**Crawl complete when:**
- [ ] All switches installed and labeled
- [ ] VLANs tested (can ping correctly, can't ping incorrectly)
- [ ] 5 core automations running reliably
- [ ] Household members have used Siri successfully 3+ times
- [ ] Git tag: `crawl-complete`

**Walk complete when:**
- [ ] All sensors deployed and reporting
- [ ] Climate automations running
- [ ] Rachio weather intelligence verified
- [ ] Notifications categorized and non-spammy
- [ ] Git tag: `walk-complete`

**Run complete when:**
- [ ] mmWave presence working in all target rooms
- [ ] Tablets deployed and dashboards polished
- [ ] Household documentation printed and distributed
- [ ] 30-day stability achieved
- [ ] Git tag: `run-complete`

### Prerequisite Dependencies {#dependencies}

Before starting any task, verify prerequisites are complete:

**Smart Locks require:**
- Network VLANs configured (locks need IoT VLAN)
- HA server running reliably
- Nabu Casa configured (for Apple Home integration)

**Motion-based lighting requires:**
- Smart switches installed in target room
- Motion sensor paired and reporting
- Time-of-day conditions decided

**Presence-based automations require:**
- HA Companion app on all tracked phones
- Zones configured in HA
- "Everyone" group created

---

## Future Expansion Ideas {#future}

**Not in 18-month plan, but consider later:**

- Security cameras (wired, local storage via Frigate)
- Video doorbell (local-first options emerging)
- EV charger integration (if you get an EV)
- Whole-home audio (beyond Sonos)
- Advanced climate zones (duct dampers, room sensors)
- Automated pet feeder/door (if you get pets)
- Pool/hot tub automation (if added)
- Holiday lighting automation (RGB strips, outdoor lights)
- Voice assistant in every room (Wyoming satellites)
- Self-hosted LLM integration (local AI assistant)

---

## Appendices {#appendices}

### A. Floor Plans {#appendix-floor-plans}

See `floor-plans/` folder for:

- First floor layout with dimensions
- Second floor layout with dimensions
- Annotated device placement map (created during deployment)

### B. Network Diagrams {#appendix-network}

See `architecture/network.md` for:

- Physical topology
- Logical VLAN layout
- Firewall rule details
- IP addressing scheme

### C. Shopping Lists {#appendix-shopping}

See phase documents for:

- Crawl: `phases/crawl.md`
- Walk: `phases/walk.md`
- Run: `phases/run.md`

### D. Integration Guides {#appendix-integrations}

See `integrations/` folder for device-specific setup notes

### E. Configuration Templates {#appendix-templates}

See `config-templates/` folder for YAML examples

---

## Known Issues & Workarounds {#known-issues}

### Sonos Integration {#sonos-issues}

**Issue:** Sonos speakers disappear after HA update
**Cause:** Sonos firmware update breaks integration
**Solution:**
1. Check HA community forums for similar reports
2. Wait 2-3 days for HA integration update
3. Temporary: Control via Sonos app
4. DO NOT remove/re-add integration (makes it worse)

**Issue:** TTS announcements cut off first word
**Cause:** Speaker needs wake-up time
**Solution:**
```yaml
# Add brief audio before message
action:
  - service: media_player.volume_set
    target:
      entity_id: media_player.living_room
    data:
      volume_level: 0.5
  - delay: 0.3
  - service: tts.speak
    target:
      entity_id: tts.google_en
    data:
      media_player_entity_id: media_player.living_room
      message: "Your message here"
```

### Kwikset Halo Integration {#kwikset-issues}

**Issue:** Lock shows "unavailable" periodically
**Cause:** WiFi signal strength issues or cloud API timeout
**Solution:**
1. Check WiFi signal at lock location (need >-65 dBm)
2. Add WiFi extender if needed
3. Lock still works manually and via codes
4. HA will reconnect automatically

**Issue:** Fingerprint updates require Kwikset app
**Limitation:** Cannot add fingerprints via HA
**Workaround:** Use Kwikset app for fingerprint management, HA for everything else

### Zigbee Mesh Issues {#zigbee-issues}

**Issue:** Devices dropping off network
**Cause:** Weak mesh, interference, or coordinator placement
**Solution:**
1. Ensure coordinator is on USB extension (away from USB 3.0 ports)
2. Add powered devices first (they act as routers)
3. Battery devices should be added last
4. Check ZHA map for weak links

**Issue:** Pairing fails repeatedly
**Cause:** Device too far from router, or interference
**Solution:**
1. Pair device near coordinator
2. Move to final location after pairing
3. Wait 24 hours for mesh to stabilize

---

## Pre-Installation Checklists {#checklists}

### Before Installing Any Smart Switch {#switch-checklist}

- [ ] **TURN OFF BREAKER** - Verify with non-contact voltage tester
- [ ] Photograph existing wiring (for rollback reference)
- [ ] Verify neutral wire exists (white wire bundle in box)
- [ ] Measure box depth if unsure (need ≥2.5" for Inovelli)
- [ ] Identify if 3-way/4-way (requires different wiring)
- [ ] Have manual override plan (keep old switch as backup until confirmed working)
- [ ] Label wires before disconnecting

### Before Adding Any Integration {#integration-checklist}

- [ ] Read HA documentation for integration
- [ ] Check GitHub issues for known problems
- [ ] Verify device firmware is current
- [ ] Back up HA configuration
- [ ] Document current state (in case rollback needed)
- [ ] Test in isolation before connecting to automations

### Before Creating Any Automation {#automation-checklist}

- [ ] Define the specific problem being solved
- [ ] Identify trigger, conditions, and actions
- [ ] Determine failure mode (what happens if trigger fails?)
- [ ] Plan manual override mechanism
- [ ] Write in test mode first (notifications only)
- [ ] Run for 48+ hours before enabling actions

---

## Document Control {#document-control}

**Created:** December 2024
**Last updated:** December 2024
**Next review:** End of Crawl phase (Month 3)
**Owner:** Kendrick (homeowner)
**Status:** Living document (update as project evolves)

---

**Let's build something awesome.** 🏠🚀
