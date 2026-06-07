# Network Contracts

<!-- This file occupies the kit's dataContracts.md slot, repurposed for a -->
<!-- homelab project. The "contracts" here are the conventions between HA, -->
<!-- devices, and the network — entity naming, VLAN/IP plan, protocol -->
<!-- assignments. The PRD has the narrative; this file is the agent-facing -->
<!-- summary. -->

## Entity naming convention

**Pattern:** `{domain}.{floor}_{room}_{fixture}[_{detail}]`

**Examples:**
- `light.first_kitchen_island` — first floor, kitchen, island light
- `light.second_bedroom_2_ceiling` — second floor, bedroom 2, ceiling light
- `switch.first_garage_opener` — first floor, garage, opener switch
- `sensor.second_bath_1_leak` — second floor, bathroom 1, leak sensor
- `lock.first_front_door` — first floor, front door lock

**Floor prefixes:** `first_`, `second_`, `garage_` (separate from first), `outdoor_`

**Room abbreviations (only when needed for length):** `br` (bedroom), `bath` (bathroom), `lr` (living room), `fr` (family room), `kit` (kitchen)

**UPS / NUT entities (per [ADR-011](../docs/decisions.md#adr-011)):** follow the same `{domain}.{floor}_{room}_{detail}` grammar — e.g. `sensor.first_office_ups_battery_charge`, `sensor.first_office_ups_load`, `sensor.first_office_ups_status`. Verify the office floor prefix against the actual house layout before naming; if the office isn't on the first floor, substitute the correct prefix.

**Source of truth:** PRD §Entity Naming Convention.

## VLAN / IP plan

| VLAN | Purpose                                | IP range          | Notes                                                      |
| ---- | -------------------------------------- | ----------------- | ---------------------------------------------------------- |
| 1    | Default / Trusted                      | 192.168.1.x       | Phones, laptops, Apple TVs                                 |
| 10   | IoT                                    | 192.168.10.x      | All smart-home devices; firewall-limited to known endpoints |
| 20   | Guest                                  | 192.168.20.x      | No access to other VLANs                                   |
| 30   | Servers                                | 192.168.30.x      | Proxmox host (.5), HA VM (.10), future LXCs                |

**Firewall rules (high-level):**
- VLAN 1 → VLAN 10, VLAN 30: ALLOW (users control devices and services)
- VLAN 10 → VLAN 30: ALLOW (devices talk to HA)
- VLAN 10 → VLAN 1: DENY (compromised IoT cannot pivot to personal devices)
- VLAN 10 → Internet: DENY except whitelisted firmware-update endpoints
- VLAN 20 → anything else: DENY

**Static IPs (planned, not yet assigned):**
- Proxmox host: `192.168.30.5`
- HA OS VM (VM 200): `192.168.30.10`
- Forgejo LXC (CT 100): `192.168.30.20`
- Claude Code dev LXC (CT 101): `192.168.30.21`

**Source of truth:** PRD §Network Architecture + ADR-003.

## Protocol assignments

| Protocol  | Use case                          | Default? | Rationale                                                |
| --------- | --------------------------------- | -------- | -------------------------------------------------------- |
| Zigbee    | Switches, sensors, locks          | Yes      | Local, mesh, mature. See ADR-002.                        |
| WiFi      | Cameras, TVs, Kwikset locks       | Fallback | Only when no Zigbee alternative or feature requires it.  |
| Z-Wave    | Smoke detectors via Resideo panel | Limited  | Leverages builder-installed hardware. See ADR-006.       |
| Matter    | Future devices                    | Wait     | Ecosystem maturing; revisit late WALK / early RUN.       |
| Hardwired | Thermostats, garage opener        | Where possible | Most reliable; no battery / wireless concerns.     |

## Homelab CT/VM ID allocation

| ID     | Type | Role                                | Notes                                  |
| ------ | ---- | ----------------------------------- | -------------------------------------- |
| CT 100 | LXC  | Forgejo (native, unprivileged)      | See ADR-007                            |
| CT 101 | LXC  | Claude Code dev (unprivileged)      | See ADR-010                            |
| VM 200 | VM   | Home Assistant OS                   | USB passthrough for Zigbee coordinator |
| CT/VM 1xx, 2xx, ... | reserved | future homelab services | Native LXC default per ADR-009         |
