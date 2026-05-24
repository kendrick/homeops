# Device Inventory

**Last updated:** December 2025

Track all smart home devices here. Update as you purchase and install.

---

## Template for New Devices

```markdown
### Device Name

- **Make/Model:**
- **Purchase Date:**
- **Purchase Price:**
- **Location:**
- **Entity ID:**
- **Protocol:** (Zigbee/WiFi/Z-Wave/Hardwired)
- **VLAN:** (if applicable)
- **MAC Address:**
- **Notes:**
```

---

## Infrastructure

### Home Assistant Server

- **Make/Model:** Repurposed PC (5 years old)
- **Purchase Date:** N/A (already owned)
- **Location:** Office/Study
- **OS:** Home Assistant OS
- **Storage:** [TBD]
- **RAM:** [TBD]
- **CPU:** [TBD]
- **Notes:** Running HA + future self-hosted services

### Zigbee Coordinator

- **Make/Model:** Sonoff ZBDongle-E (ZigBee 3.0 USB Dongle Plus)
- **Purchase Date:** [TBD]
- **Purchase Price:** ~$20
- **Location:** Office (plugged into HA server)
- **Notes:** Using USB extension cable to reduce interference

### Network Switch

- **Make/Model:** TP-Link TL-SG108PE
- **Purchase Date:** [TBD]
- **Purchase Price:** ~$70
- **Location:** Network cabinet (fiber entry point)
- **Notes:** 8-port PoE+, manages VLANs

### Router

- **Make/Model:** [TBD - GL.iNet Flint 2 recommended]
- **Purchase Date:** [TBD]
- **Purchase Price:** ~$180
- **Location:** Network cabinet
- **Notes:** Handles VLAN segmentation, firewall rules

---

## Lighting (Switches & Dimmers)

### Kitchen - Island Switch

- **Make/Model:**
- **Purchase Date:**
- **Purchase Price:**
- **Location:** Kitchen wall, right of sink
- **Entity ID:** `light.first_kitchen_island`
- **Protocol:**
- **Notes:** Controls pendant lights over island

[Add more switches as installed...]

---

## Security (Locks & Sensors)

### Front Door Lock

- **Make/Model:** Kwikset Halo Touch
- **Purchase Date:** [TBD]
- **Purchase Price:** ~$280
- **Location:** Front entry
- **Entity ID:** `lock.first_front_door`
- **Protocol:** WiFi
- **VLAN:** IoT (VLAN 10)
- **MAC Address:** [TBD]
- **User Codes:** Template — real codes and per-user attribution live outside this repo (local-only or private companion).
  - Code 1: User 1
  - Code 2: User 2
  - Code 3-6: Additional users
  - Code 7: Guest (temporary)
- **Fingerprints:** Template — real enrollment lives outside this repo.
  - User 1: 3 fingers
  - User 2: 2 fingers
- **Notes:** SmartKey compatible, shares cores with old Kwikset locks. Do NOT commit actual codes or per-user attribution to this repo.

[Add more locks and sensors as installed...]

---

## Climate Control

### Upstairs Thermostat

- **Make/Model:** Honeywell T6 Pro
- **Purchase Date:** N/A (builder-installed)
- **Location:** Upstairs hallway
- **Entity ID:** `climate.upstairs`
- **Protocol:** WiFi
- **VLAN:** IoT (VLAN 10)
- **MAC Address:** [TBD]
- **Notes:** Controls upstairs HVAC zone

### Garage Mini-Split

- **Make/Model:** [TBD]
- **Purchase Date:** [TBD]
- **Location:** Garage ceiling
- **Control:** Broadlink RM4 Pro (IR blaster)
- **Notes:** DIY installation planned for Walk phase

---

## Irrigation

### Rachio 3 Controller

- **Make/Model:** Rachio 3 (8-zone)
- **Purchase Date:** N/A (already owned)
- **Location:** [TBD - garage or exterior]
- **Entity ID:** [TBD]
- **Protocol:** WiFi
- **VLAN:** IoT (VLAN 10)
- **Zones:**
  1. Front lawn
  2. Back lawn left
  3. Back lawn right
  4. [TBD]
  5. Trees drip (new - Walk phase)
  6. Garden drip (new - Walk phase)
     7-8. [TBD]
- **Notes:** Weather intelligence enabled

---

## Entertainment

### Living Room Apple TV

- **Make/Model:** Apple TV 4K
- **Purchase Date:** N/A (already owned)
- **Location:** Living room / family room
- **Entity ID:** `media_player.living_room_apple_tv`
- **Protocol:** WiFi
- **VLAN:** Default (VLAN 1)
- **Notes:** Primary entertainment hub

[Add more Apple TVs and Sonos speakers as installed...]

---

## Sensors

### Water Leak - Kitchen Sink

- **Make/Model:** Aqara Water Leak Sensor
- **Purchase Date:** [TBD]
- **Purchase Price:** ~$20
- **Location:** Under kitchen sink
- **Entity ID:** `binary_sensor.kitchen_sink_leak`
- **Protocol:** Zigbee
- **Battery:** CR2032
- **Last Battery Change:** [TBD]
- **Notes:**

[Add more sensors as installed...]

---

## Voice Assistants

### Kitchen HomePod mini

- **Make/Model:** HomePod mini
- **Purchase Date:** [TBD]
- **Purchase Price:** ~$100
- **Location:** Kitchen counter
- **Protocol:** WiFi
- **VLAN:** Default (VLAN 1)
- **Notes:** Primary voice control for the household

[Add more HomePods as installed...]

---

## Maintenance Schedule

### Battery-Powered Devices

| Device             | Battery Type | Last Changed | Next Change  | Notes |
| ------------------ | ------------ | ------------ | ------------ | ----- |
| Water leak sensors | CR2032       | N/A          | Check yearly |       |
| Door sensors       | CR2032       | N/A          | Check yearly |       |
| Motion sensors     | CR2032       | N/A          | Check yearly |       |

### Firmware Updates

| Device            | Current Version | Last Updated | Auto-Update? |
| ----------------- | --------------- | ------------ | ------------ |
| HA Server         |                 |              | No (manual)  |
| Inovelli switches |                 |              | Via HA       |
| Kwikset locks     |                 |              | Via app      |
| Rachio            |                 |              | Yes          |

---

## Decommissioned Devices

Track devices you've replaced or removed:

### Old ISP Router

- **Replaced by:** GL.iNet Flint 2
- **Date removed:** [TBD]
- **Reason:** Needed VLAN support
- **Disposition:** Stored as backup

---

## Wishlist / Future Purchases

Devices you're considering but haven't bought yet:

- [ ] Security cameras (Frigate-compatible)
- [ ] Video doorbell (local-first)
- [ ] EV charger integration
- [ ] Pool/hot tub automation
- [ ] Outdoor smart plugs for holiday lights

---

**Keep this updated! It's your source of truth for troubleshooting and expansion.**
