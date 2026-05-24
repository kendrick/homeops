# CRAWL Phase: Months 0-3 {#crawl}

## Fix Annoyances, Build Foundation

**Budget:** $1,500-2,500
**Timeline:** 12 weeks
**Status:** Not started

**PRD Reference:** [Phase 1: CRAWL](../prd.md#phase-crawl)

> **This document is a reading guide.** Implementation steps live in GitHub
> issues (CRAWL-01..15) and are planned in-session at execution time. Don't
> add per-task procedural detail here — it rots before it's executed.
> Issue bodies are thin briefs; the actual plan emerges from a planning
> session against the current state of the world.

---

## Phase Goals {#crawl-goals}

- Solve the "lights left on in empty rooms upstairs" problem
- Know which switches control which lights / fans (audit + label)
- Mood lighting in evenings (automation + dimming)
- Rock-solid Home Assistant infrastructure (Proxmox + HA OS VM)
- Network segmentation for security (VLANs, firewall rules)
- Smart locks for convenience + security
- Basic presence detection (phone-based)
- Core automations working reliably (5 from PRD)

---

## Week-by-week (theme + issues)

### Week 1-2: Homelab foundation + HA install {#week-1-2}

**Theme:** Stand up Proxmox on the i5-11400 box; deploy HA OS VM, Forgejo LXC, Claude Code dev LXC; wire Tailscale; enable two-layer backups.

**Deliverable:** Proxmox host running 24/7 with `homeassistant.local:8123` reachable, Forgejo reachable over the tailnet, Claude Code SSH-able from off-network.

**Issues:**
- **CRAWL-01:** Bootstrap Proxmox VE
- **CRAWL-02:** Forgejo on native LXC (CT 100) — see [ADR-007](../decisions.md#adr-007), [ADR-009](../decisions.md#adr-009)
- **CRAWL-03:** Tailscale on Forgejo + dev LXCs — see [ADR-008](../decisions.md#adr-008)
- **CRAWL-04:** Claude Code on dedicated dev LXC (CT 101) — see [ADR-010](../decisions.md#adr-010)
- **CRAWL-05:** Home Assistant OS VM (VM 200) on existing Proxmox
- **CRAWL-06:** Essential HA add-ons (File Editor, Terminal & SSH, Samba, Studio Code Server)
- **CRAWL-07:** Three-layer backup strategy (Proxmox snapshots + vzdump + HA native)
- **CRAWL-08:** Nabu Casa for remote HA access + Siri — see [ADR-004](../decisions.md#adr-004)

**Key references:** PRD [§Platform Stack](../prd.md#platform-stack), [networkContracts.md](../../_working-memory/networkContracts.md) for CT/VM ID allocation and static-IP plan.

**Resideo panel inventory** (no-purchase prep work, can run in parallel): document zones via panel UI, test HomeKit pairing, research Z-Wave capability. Outcome lands in `inventory.md`.

---

### Week 2-4: Network rebuild + Zigbee {#week-2-4}

**Theme:** VLAN-segmented network (Trusted / IoT / Guest / Servers) + Zigbee coordinator with USB passthrough to the HA VM.

**Deliverable:** IoT devices isolated; HA on VLAN 30; firewall rules pass the four canonical ping tests (see [PRD §Network Segmentation](../prd.md#network-architecture)). Zigbee mesh operational.

**Issues:**
- **CRAWL-09:** Zigbee coordinator + USB passthrough — see [ADR-002](../decisions.md#adr-002)
- **CRAWL-10:** Network rebuild (managed switch + router + VLAN configuration + firewall rules) — see [ADR-003](../decisions.md#adr-003)

**Hardware needed:** Sonoff ZBDongle-E (~$20), TP-Link TL-SG108PE (~$70), GL.iNet Flint 2 router (~$180), USB extension cable.

**Reference:** PRD [§Network Mistakes](../prd.md#network-mistakes) — read before configuring.

---

### Week 3-6: Lighting overhaul {#week-3-6}

**Theme:** Map every switch (audit first), order the mix (Inovelli Blue for high-traffic, Shelly relays for shallow boxes), install in priority order (upstairs first — solves the leftover-lights problem).

**Deliverable:** 20-25 smart switches installed and labeled; all entities renamed per the [naming convention](../../_working-memory/networkContracts.md#entity-naming-convention); manual override tested with HA offline.

**Issues:**
- **CRAWL-11:** Switch audit + Resideo panel inventory (painter's tape walkthrough; spreadsheet of every switch + room + type + box depth)
- **CRAWL-12:** Lighting rollout — parameterized; per-room checklist sub-tasks rather than one issue per room. Order: upstairs (kids' bedrooms / game room / bath) → main living (family room / kitchen / dining) → personal (office / owner's bedroom & bath) → outdoor (patio / porch / garage). See [ADR-005](../decisions.md#adr-005) for the Inovelli vs Shelly call.

**Hardware needed:** Inovelli Blue switches (~15 units, ~$825-1,050); Shelly relays (~10 units, ~$120-150); label maker.

**Per-switch installation:** complete the [PRD §Switch Checklist](../prd.md#switch-checklist) before touching wires.

---

### Week 6-8: Smart locks {#week-6-8}

**Theme:** Front + back door locks (Kwikset Halo Touch on front, Halo on back), codes programmed, fingerprints enrolled (per-household-member; real attribution lives outside this repo).

**Deliverable:** Both doors smart-locked, working in HA + Apple Home, codes programmed, auto-lock automation tested.

**Issues:**
- **CRAWL-13:** Smart locks (front + back) install + HA integration

**Prerequisites:** Network VLANs configured ✓ (CRAWL-10), HA running ✓ (CRAWL-05), Nabu Casa configured ✓ (CRAWL-08).

**Hardware needed:** Kwikset Halo Touch front (~$280), Kwikset Halo back (~$200).

**Read before installing:** PRD [§Kwikset Halo Integration Issues](../prd.md#kwikset-issues).

---

### Week 8-10: Presence + Resideo→HA bridge {#week-8-10}

**Theme:** Phone-based presence detection via HA Companion; expose HA devices back to the Resideo touchscreen via HomeKit.

**Deliverable:** "Home" / "Away" state accurate per household member; Resideo panel can control HA-managed devices.

**Issues:**
- **CRAWL-14:** Presence detection (HA Companion app on all household phones + zones configured + Everyone group helper)

**Prerequisites:** HA Companion app on all tracked phones; zones configured in HA; Person entities created.

---

### Week 10-12: Core automations + polish {#week-10-12}

**Theme:** Ship the five core automations from the PRD; expose to Apple Home; build a simple dashboard.

**Deliverable:** 5 automations running reliably, Apple Home synced, Siri responding to common commands, dashboard usable from kitchen tablet.

**Issues:**
- **CRAWL-15:** Core automations (the 5 from PRD §Phase 1 Crawl) + Apple Home scene setup + simple dashboard

**The 5 automations:**
1. **Leaving Home** (`presence_everyone_leaving_secure`) — everyone away → lights off, doors locked, notify
2. **Evening Warm** (`time_house_evening_warm`) — 30 min before sunset → lights to warm white 60%
3. **Evening Dim** (`time_upstairs_evening_dim`) — 9 PM → upstairs lights to 30% over 60s
4. **Late Night Off** (`time_house_latenight_off`) — 11:30 PM → all lights off except primary bedroom, lock doors
5. **Goodnight Scene** (`scene_house_goodnight_secure`) — iOS Shortcut trigger → secure house

**Automation template:** see PRD [§Automation Template](../prd.md#automation-template). All automations follow [§Before Creating Any Automation](../prd.md#automation-checklist).

---

## Shopping list {#crawl-shopping}

| Category       | Items                                                              | Subtotal       |
| -------------- | ------------------------------------------------------------------ | -------------- |
| Infrastructure | Sonoff ZBDongle-E, TP-Link TL-SG108PE, GL.iNet Flint 2, USB ext.   | ~$330          |
| Lighting       | Inovelli Blue switches (15×), Shelly relays (10×), labels          | ~$975-1,230    |
| Locks          | Kwikset Halo Touch (front), Kwikset Halo (back)                    | ~$480          |
| Services       | Nabu Casa (3 months)                                               | ~$20           |
| **Total**      |                                                                    | **~$1,805-2,060** |

Contingency: ~$200-700 within phase budget.

---

## Testing checklist {#crawl-testing}

Test against PRD [§Success Metrics](../prd.md#success-metrics) and [§Quantitative Metrics](../prd.md#quantitative-metrics).

**Infrastructure**
- [ ] HA uptime >99% over last 2 weeks
- [ ] Backups running daily (all three layers verified)
- [ ] Remote access working from outside network (Tailscale + Nabu Casa)
- [ ] VLANs properly isolating IoT devices (four canonical ping tests)

**Lighting**
- [ ] All switches installed and physically labeled
- [ ] Manual overrides work with HA offline
- [ ] Evening mode triggers reliably at sunset
- [ ] No flickering or disconnection issues

**Locks**
- [ ] Both locks working in HA + Apple Home
- [ ] All codes programmed and tested
- [ ] Auto-lock working

**Presence**
- [ ] Leaving home automation triggers correctly
- [ ] Arriving home automation triggers correctly
- [ ] Battery impact <5% per device

**Automations**
- [ ] All 5 automations triggering 100% reliably under expected conditions

**Household acceptance** (HAF — per PRD [§Success Criteria](../prd.md#success-criteria))
- [ ] Primary household member uses Siri to control lights (≥3 commands tested)
- [ ] No complaints about broken features in the last week
- [ ] ≥1 voluntary "this is cool!" reaction

---

## Success metrics (end of CRAWL) {#crawl-success}

Per PRD [§Phase 1 Success Metrics](../prd.md#phase-crawl).

**Must achieve**
- [ ] Zero "lights left on in empty rooms" incidents in last 2 weeks
- [ ] 100% manual override success rate
- [ ] HA uptime >99%
- [ ] Household satisfaction score ≥8/10

**Should achieve**
- [ ] All switches labeled and documented in `inventory.md`
- [ ] 5+ automations running reliably
- [ ] Apple Home fully synced
- [ ] Siri working for common commands

**Stretch**
- [ ] Custom dashboard looks polished
- [ ] Energy usage baseline measured
- [ ] Household members suggesting new automations
- [ ] Guests impressed by the setup

---

## Troubleshooting

Issue-specific troubleshooting lives in [`docs/troubleshooting.md`](../troubleshooting.md). Read before opening a session about a misbehaving device.

For integration-specific gotchas: PRD [§Known Issues & Workarounds](../prd.md#known-issues).

---

## Lessons learned

Fill out at end of phase. Append to this section.

**What went well:**

**What was harder than expected:**

**What would you do differently:**

**What surprised you:**

**Recommendations for WALK phase:**

---

## Phase completion checklist {#crawl-complete}

Per PRD [§Phase Completion Markers](../prd.md#phase-markers).

- [ ] All switches installed and labeled
- [ ] VLANs tested (pings pass the four canonical cases)
- [ ] 5 core automations running reliably
- [ ] Household members have used Siri successfully ≥3 times
- [ ] `inventory.md` reflects everything that's actually deployed
- [ ] Git tag: `crawl-complete`

---

## Next phase preview {#crawl-next}

**WALK focus:** PRD [§Phase 2: WALK](../prd.md#phase-walk).

- Comprehensive sensor network (door / window / water leak / motion)
- Climate control expansion (garage mini-split, Rachio)
- Entertainment integration (Apple TV, Sonos)
- Advanced notifications

**Prep for WALK** (during late CRAWL):
- Finalize garage mini-split install timeline
- Order sensor batch (~20-30 sensors)
- Research mmWave sensors
- Plan drip irrigation zones
