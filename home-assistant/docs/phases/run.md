# RUN Phase: Months 9-18 {#run}

## Perfect the Experience

**Budget:** $2,000-5,000 (flexible)
**Timeline:** 9 months
**Status:** Not started (complete Walk first)

**PRD Reference:** [Phase 3: RUN](../prd.md#phase-run)

---

## Phase Goals {#run-goals}

✅ Near-perfect presence detection (mmWave)
✅ Smart window coverings on problem windows
✅ Whole-home energy monitoring
✅ Voice control perfection (HomePods)
✅ Smoke/CO integration
✅ Garage fully automated
✅ Guest-friendly UI (tablets + dashboards)
✅ Complete household documentation

---

## Prerequisites {#run-prerequisites}

Before starting Run phase, verify Walk is complete per [PRD § Phase Completion Markers](../prd.md#phase-markers):

- [ ] All sensors deployed and reporting
- [ ] Climate automations running
- [ ] Rachio weather intelligence verified
- [ ] Notifications categorized and non-spammy
- [ ] Git tag: `walk-complete` exists

---

## Month-by-Month Breakdown

### Month 10-11: Advanced Presence Detection {#month-10-11}

#### mmWave Sensor Selection

**Why mmWave over PIR motion sensors:**
- Detects stationary presence (reading, watching TV)
- No "lights turned off while I was still here"
- Zone-based detection (desk vs couch)
- Works through thin obstructions

**Recommended Models:**

| Model | Zones | Price | Best For |
|-------|-------|-------|----------|
| Aqara FP2 | 30 zones | ~$80 | Large rooms, multiple zones |
| Everything Presence One (EP1) | 3 zones | ~$40 | Single-purpose rooms |
| Aqara FP1 | 1 zone | ~$50 | Small rooms, closets |

**mmWave Sensors (4-6× ~$200-480)**

Deployment zones (priority order):

- [ ] Office (3 zones: desk, lounge, maker space)
  - **Critical:** Detects "working at desk" vs "taking a break"
  - Use Aqara FP2 for zone support
- [ ] Owner's bedroom (2 zones: bed vs moving)
  - **Prevents:** Lights off while reading in bed
- [ ] Living room (2 zones: couch, walking)
  - **Enables:** Movie lights don't kill while you're sitting
- [ ] Kitchen (1 zone: cooking area)
  - **Enables:** Lights stay on while cooking

**Installation:**

Complete [PRD § Before Adding Any Integration](../prd.md#integration-checklist) before setup.

For each sensor:
- [ ] Mount at ceiling or high wall (2.5-3m height optimal)
- [ ] Aim at activity area, avoid windows (false triggers)
- [ ] Add to HA via manufacturer integration
- [ ] Configure zones in sensor app/HA
- [ ] Test: Sit still for 5 minutes, verify "occupied" state
- [ ] Name using [PRD § Entity Naming Convention](../prd.md#entity-naming): `binary_sensor.first_office_presence`

**mmWave Automations:**

```yaml
# File: automations/presence_office_follow_me.yaml
alias: "Presence - Office - Follow Me"
description: >
  WHAT: Track which zone of office is occupied, adjust lighting
  WHY: Different activities need different light levels
  OVERRIDE: Manual light control; will resume on next detection

trigger:
  - platform: state
    entity_id: sensor.office_mmwave_zone
    id: zone_change

condition:
  - condition: state
    entity_id: binary_sensor.first_office_presence
    state: 'on'

action:
  - choose:
      - conditions:
          - condition: state
            entity_id: sensor.office_mmwave_zone
            state: 'desk'
        sequence:
          - service: light.turn_on
            target:
              entity_id: light.first_office
            data:
              brightness_pct: 100
              kelvin: 4500  # Cool for focus
      - conditions:
          - condition: state
            entity_id: sensor.office_mmwave_zone
            state: 'lounge'
        sequence:
          - service: light.turn_on
            target:
              entity_id: light.first_office
            data:
              brightness_pct: 60
              kelvin: 3000  # Warmer for relaxing
    default:
      - service: light.turn_on
        target:
          entity_id: light.first_office
        data:
          brightness_pct: 80

mode: restart
id: presence_office_follow_me
```

**Room-to-Room Following:**

```yaml
# File: automations/presence_rooms_follow.yaml
alias: "Presence - Rooms - Follow"
description: >
  WHAT: Turn on lights when entering room, off when leaving
  WHY: Hands-free lighting; energy savings
  OVERRIDE: Manual switch; automation resumes on next transition

trigger:
  - platform: state
    entity_id:
      - binary_sensor.first_office_presence
      - binary_sensor.first_living_room_presence
      - binary_sensor.first_kitchen_presence
      - binary_sensor.first_owner_bedroom_presence

condition:
  - condition: sun
    after: sunset

action:
  - choose:
      - conditions:
          - condition: template
            value_template: "{{ trigger.to_state.state == 'on' }}"
        sequence:
          - service: light.turn_on
            target:
              entity_id: "light.{{ trigger.entity_id | replace('binary_sensor.', '') | replace('_presence', '') }}"
            data:
              brightness_pct: 80
      - conditions:
          - condition: template
            value_template: "{{ trigger.to_state.state == 'off' }}"
        sequence:
          - delay:
              seconds: 30  # Grace period
          - condition: state
            entity_id: "{{ trigger.entity_id }}"
            state: 'off'  # Still unoccupied
          - service: light.turn_off
            target:
              entity_id: "light.{{ trigger.entity_id | replace('binary_sensor.', '') | replace('_presence', '') }}"

mode: queued
max: 10
id: presence_rooms_follow
```

---

### Month 12-13: Smart Window Coverings {#month-12-13}

#### Problem Windows Assessment

Identify windows that:
- Get direct sun (heat gain, glare)
- Face street (privacy)
- Are hard to reach manually

**Target Windows: 5×36" + 1×48"**

#### Option Comparison

**Option 1: IKEA Fyrtur (~$900-1,200 total)**

Pros:
- Budget-friendly (~$150-200 per blind)
- Zigbee (local control)
- Easy HA integration via ZHA
- Battery-powered (no wiring)

Cons:
- Limited custom sizing
- 6-month battery life (need to recharge)
- Basic aesthetics

**Option 2: Lutron Serena (~$1,500-2,400 total)**

Pros:
- Premium quality
- Custom sizing available
- Excellent reliability (Lutron = gold standard)
- Longer battery life

Cons:
- Requires Lutron hub (~$180)
- Expensive
- Proprietary protocol

**Recommendation per [PRD § Non-Negotiables](../prd.md#non-negotiables):**

IKEA Fyrtur for Zigbee local control, unless custom sizing needed.

#### Installation

- [ ] Measure all target windows (inside mount)
- [ ] Order closest matching sizes
- [ ] Install per IKEA instructions
- [ ] Pair via ZHA: Settings → Devices → Add Device
- [ ] Name: `cover.first_living_room_window_1`
- [ ] Test: Open/close from HA
- [ ] Set position limits if needed

#### Blind Automations

```yaml
# File: automations/time_blinds_morning.yaml
alias: "Time - Blinds - Morning"
description: >
  WHAT: Open blinds at sunrise (or 8 AM, whichever later)
  WHY: Natural wake-up; daylight
  OVERRIDE: Close blinds manually; will reopen next day

trigger:
  - platform: sun
    event: sunrise
    offset: "+00:30:00"
  - platform: time
    at: "08:00:00"

condition:
  - condition: time
    after: "08:00:00"
    before: "20:00:00"
  - condition: state
    entity_id: input_boolean.vacation_mode
    state: 'off'

action:
  - service: cover.open_cover
    target:
      entity_id:
        - cover.first_living_room_window_1
        - cover.first_living_room_window_2
        - cover.first_owner_bedroom

mode: single
id: time_blinds_morning
```

```yaml
# File: automations/climate_blinds_sun.yaml
alias: "Climate - Blinds - Sun"
description: >
  WHAT: Close blinds when direct sun hits (based on sun position)
  WHY: Reduce heat gain; energy savings
  OVERRIDE: Open blinds manually; will re-close if sun angle triggers

trigger:
  - platform: numeric_state
    entity_id: sun.sun
    attribute: azimuth
    above: 180  # Adjust for your window orientation
    below: 270

condition:
  - condition: numeric_state
    entity_id: sensor.outdoor_temperature
    above: 75  # Only in warm weather

action:
  - service: cover.close_cover
    target:
      entity_id:
        - cover.first_living_room_window_1  # West-facing

mode: single
id: climate_blinds_sun
```

---

### Month 14: Energy Monitoring {#month-14}

#### Emporia Vue 2 Setup

See [PRD § Integrations - Lower Priority](../prd.md#integrations-run).

**Hardware Installation:**

⚠️ **WARNING:** Work in electrical panel requires breaker OFF. If uncomfortable, hire electrician.

- [ ] Turn off main breaker
- [ ] Install CTs (current transformers) on circuits:
  - [ ] Main feeds (2× for whole-home total)
  - [ ] HVAC upstairs
  - [ ] HVAC downstairs (if separate)
  - [ ] Garage mini-split
  - [ ] Water heater
  - [ ] Dryer
  - [ ] Oven/range
  - [ ] Office equipment
  - [ ] EV charger (future - leave CT ready)
- [ ] Connect Emporia to WiFi (IoT VLAN)
- [ ] Turn on main breaker

**HA Integration:**

- [ ] Add integration: Settings → Integrations → Emporia Vue
- [ ] Verify all circuits reporting
- [ ] Create energy dashboard: Settings → Dashboards → Energy
- [ ] Set up utility rates for cost tracking

**Energy Automations:**

```yaml
# File: automations/notify_energy_spike.yaml
alias: "Notify - Energy - Spike"
description: >
  WHAT: Alert if unusual power spike detected
  WHY: Catch runaway appliances, potential issues
  OVERRIDE: Dismiss notification

trigger:
  - platform: numeric_state
    entity_id: sensor.emporia_vue_total_power
    above: 8000  # Adjust based on your baseline

condition:
  - condition: not
    conditions:
      - condition: state
        entity_id: climate.upstairs
        attribute: hvac_action
        state: 'heating'
      - condition: state
        entity_id: climate.downstairs
        attribute: hvac_action
        state: 'heating'

action:
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "⚡ High power usage: {{ states('sensor.emporia_vue_total_power') }}W. Check appliances."

mode: single
id: notify_energy_spike
```

---

### Month 15: Voice Control Refinement {#month-15}

#### HomePod Mini Deployment

Per [PRD § Strong Preferences](../prd.md#strong-preferences): Apple ecosystem for household.

**HomePod minis (4× ~$400)**

Locations (priority order):

- [ ] Kitchen (high traffic, cooking hands-free)
- [ ] Owner's bedroom (bedside voice control)
- [ ] Office (hands-free while working)
- [ ] Game room (household music control)

**Setup:**

- [ ] Unbox and power on each HomePod
- [ ] Add to Apple Home via iPhone
- [ ] Assign to correct rooms
- [ ] Enable Personal Requests (for individual Siri)
- [ ] Test HA-exposed scenes

**Voice Command Testing:**

Test each command from each HomePod location:

- [ ] "Hey Siri, good morning" → morning routine
- [ ] "Hey Siri, I'm leaving" → secure house
- [ ] "Hey Siri, movie time" → dim lights
- [ ] "Hey Siri, set office to focus" → work lighting
- [ ] "Hey Siri, turn off all lights"
- [ ] "Hey Siri, lock the front door"

**Common Voice Command Issues:**

Per [PRD § Known Issues](../prd.md#known-issues):

❌ **Issue:** "Siri didn't understand"
✅ **Fix:** Check device is exposed to Apple Home, restart Nabu Casa

❌ **Issue:** Wrong device responds
✅ **Fix:** Check room assignments in Apple Home

❌ **Issue:** Scene doesn't run
✅ **Fix:** Verify scene name in Apple Home matches exactly

#### Optional: Wyoming Satellites

**For tinkerers only.** Full local voice assistant.

- Requires: ESP32 device + microphone
- More complex setup than HomePod
- Fully local (privacy++)
- Custom wake words possible

See: https://github.com/rhasspy/wyoming for setup guide.

---

### Month 16: Smoke/CO Integration {#month-16}

**CRITICAL SAFETY FEATURE.** Do not skip.

#### Option Comparison

**Option 1: First Alert Z-Wave (~$540 total)**

- Requires Z-Wave USB stick (~$40) - e.g., Zooz ZST10
- ZCOMBO-G (smoke + CO, 7 units needed)
- Local control, no cloud
- Interconnected (one triggers all)

**Option 2: Listener Devices (~$90 total)**

- E.g., Ecolink Firefighter
- Listens for existing alarm sounds
- Works with any detector brand
- Less reliable than direct integration

**Recommendation:** First Alert Z-Wave for reliability.

#### Texas Code Requirements

Per Texas building code:

- [ ] Each bedroom (4 units)
- [ ] Hallway outside bedrooms (1 unit)
- [ ] Each level (2 units minimum)
- [ ] Total: 7 units needed

#### Installation

- [ ] Add Z-Wave coordinator to HA (if not already)
  - Settings → Integrations → Z-Wave JS
  - Select Z-Wave USB device
- [ ] Install detectors per manufacturer instructions
- [ ] Pair each with HA
- [ ] Test each detector (use test button)
- [ ] Verify HA shows alert state

#### Smoke/CO Automations

**CRITICAL:** These automations can save lives.

```yaml
# File: automations/safety_smoke_alert.yaml
alias: "Safety - Smoke - Alert"
description: >
  WHAT: Maximum alert on smoke detection
  WHY: Life safety - wake everyone, notify neighbors
  OVERRIDE: None - always execute

trigger:
  - platform: state
    entity_id:
      - binary_sensor.first_smoke_1
      - binary_sensor.first_smoke_2
      - binary_sensor.second_smoke_bedroom_2
      - binary_sensor.second_smoke_bedroom_3
      - binary_sensor.second_smoke_bedroom_4
      - binary_sensor.second_smoke_owner_bedroom
      - binary_sensor.second_smoke_hallway
    to: 'on'

condition: []  # ALWAYS execute

action:
  # Push to all phones with critical alert
  - service: notify.notify
    data:
      message: "🔥 SMOKE DETECTED: {{ trigger.to_state.attributes.friendly_name }}. GET OUT NOW!"
      data:
        push:
          sound:
            name: default
            critical: 1
            volume: 1.0
  # TTS on all speakers (max volume)
  - service: media_player.volume_set
    target:
      entity_id: all
    data:
      volume_level: 1.0
  - service: tts.speak
    target:
      entity_id: tts.google_en
    data:
      media_player_entity_id: all
      message: "Fire alert! Smoke detected. Evacuate the house immediately!"
  # Flash all lights
  - service: light.turn_on
    target:
      entity_id: all
    data:
      flash: long
      brightness_pct: 100
  # Flash outdoor lights (alert neighbors)
  - repeat:
      count: 10
      sequence:
        - service: light.toggle
          target:
            entity_id:
              - light.outdoor_front_porch
              - light.outdoor_back_patio
        - delay:
            seconds: 1
  # Unlock all doors (escape routes)
  - service: lock.unlock
    target:
      entity_id: all
  # Turn off HVAC (prevent smoke spread)
  - service: climate.turn_off
    target:
      entity_id: all

mode: parallel
id: safety_smoke_alert
```

---

### Month 17: Garage Automation {#month-17}

#### Garage Opener Replacement

**Why replace LiftMaster:**

Per [PRD § Current Devices](../prd.md#current-devices), existing LiftMaster Security+ 3 has proprietary lockout that blocks third-party integration.

**Replacement: Genie ChainMax 1000 (~$200-250)**

- No proprietary lockout
- Works with standard dry-contact relays
- Reliable, affordable

**Integration Hardware:**

- [ ] Tilt sensor (~$15) - Ecolink or Aqara
- [ ] Shelly 1 relay (~$12) - for control
- [ ] Optional: Beam sensor - for obstruction detection

**Installation:**

- [ ] Install Genie opener per manufacturer instructions
- [ ] Wire Shelly 1 to opener's wall button terminals
- [ ] Install tilt sensor on garage door
- [ ] Pair both to HA

**Garage Automations:**

```yaml
# File: automations/notify_garage_open.yaml
alias: "Notify - Garage - Open"
description: >
  WHAT: Alert if garage left open >15 min
  WHY: Security; weather protection
  OVERRIDE: Close manually or via notification action

trigger:
  - platform: state
    entity_id: cover.garage_door
    to: 'open'
    for:
      minutes: 15

condition:
  - condition: sun
    after: sunset

action:
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "🚗 Garage door open for 15 min. Close it?"
      data:
        actions:
          - action: "CLOSE_GARAGE"
            title: "Close Garage"
          - action: "IGNORE"
            title: "Leave Open"

mode: single
id: notify_garage_open
```

```yaml
# File: automations/presence_garage_arrival.yaml
alias: "Presence - Garage - Arrival"
description: >
  WHAT: Open garage when arriving home (geo-fence)
  WHY: Hands-free entry
  OVERRIDE: Use manual button/app

trigger:
  - platform: zone
    entity_id: person.kendrick
    zone: zone.home
    event: enter

condition:
  - condition: state
    entity_id: cover.garage_door
    state: 'closed'
  - condition: time
    after: '06:00:00'
    before: '22:00:00'

action:
  - service: cover.open_cover
    target:
      entity_id: cover.garage_door
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "🚗 Welcome home! Garage opening."

mode: single
id: presence_garage_arrival
```

---

### Month 18: UI/UX Perfection {#month-18}

#### Wall Tablets

**Fire HD 8 tablets (3× ~$200 total)**

Locations:

- [ ] Kitchen (central command)
- [ ] Entry (leaving/arriving scenes)
- [ ] Game room (household controls)

**Setup:**

- [ ] Install Fully Kiosk Browser
  - Download from Amazon App Store
  - Configure for kiosk mode (no nav bar)
- [ ] Set HA dashboard as homepage
- [ ] Enable motion wake (tablet sleeps when not used)
- [ ] Mount with adhesive or 3D-printed bracket

**Dashboard Design Principles:**

Per [PRD § Persona Guests](../prd.md#persona-guests): Design for lowest common denominator.

- **Room-based tabs** (Kitchen, Living Room, etc.)
- **Quick actions prominent** (scenes as big buttons)
- **Status at-a-glance** (door locks, temps)
- **Guest mode available** (simplified view)
- **Progressive disclosure** (advanced options hidden)

**Sample Dashboard Layout:**

```yaml
# dashboard/kitchen-tablet.yaml
views:
  - title: Home
    path: home
    icon: mdi:home
    cards:
      - type: grid
        columns: 2
        square: false
        cards:
          - type: button
            name: Good Morning
            tap_action:
              action: call-service
              service: scene.turn_on
              service_data:
                entity_id: scene.good_morning
            icon: mdi:weather-sunny
          - type: button
            name: Leaving
            tap_action:
              action: call-service
              service: script.secure_house
            icon: mdi:exit-run
          - type: button
            name: Movie Time
            tap_action:
              action: call-service
              service: scene.turn_on
              service_data:
                entity_id: scene.movie_time
            icon: mdi:movie
          - type: button
            name: Goodnight
            tap_action:
              action: call-service
              service: scene.turn_on
              service_data:
                entity_id: scene.goodnight
            icon: mdi:bed
      - type: entities
        title: Quick Status
        entities:
          - entity: lock.first_front_door
          - entity: lock.first_back_door
          - entity: cover.garage_door
          - entity: climate.upstairs
```

#### Apple Home Optimization

- [ ] Mirror HA scenes in Apple Home
- [ ] Use simple names ("Good morning" not "Morning Routine v3")
- [ ] Logical room assignments
- [ ] Add Control Center widgets

#### Discord Bot Integration (Optional)

For remote monitoring/control when away.

- [ ] Create Discord bot (free via Discord Developer Portal)
- [ ] Install AppDaemon add-on
- [ ] Create bot commands:
  - `/lights living on`
  - `/status doors`
  - `/scene movie`
  - `/camera garage` (if cameras added later)

#### Household Documentation

Per [PRD § Documentation Standards](../prd.md#documentation):

- [ ] **Printed quick-start guide** (laminated, in kitchen)
  - Basic voice commands
  - How to use scenes
  - Emergency overrides

- [ ] **Video walkthroughs** (for household members)
  - Record screen captures of common tasks
  - Store in shared Google Drive

- [ ] **Troubleshooting one-pager**
  - "If X doesn't work, try Y"
  - Emergency contacts (Kendrick's cell)

- [ ] **Voice command cheat sheet**
  - Posted near each HomePod

---

## Shopping List {#run-shopping}

### Presence Detection

- [ ] mmWave sensors (5×): ~$250-400

### Window Coverings

- [ ] Smart blinds (6 windows): ~$900-2,400

### Energy Monitoring

- [ ] Emporia Vue 2 with 16 CTs: ~$100-300

### Voice Control

- [ ] HomePod minis (4×): ~$400
- [ ] Wyoming satellites (optional): ~$40-200

### Safety

- [ ] Z-Wave USB stick: ~$40
- [ ] First Alert Z-Wave detectors (7×): ~$500

### Garage

- [ ] Genie opener: ~$200-250
- [ ] Tilt sensor + Shelly relay: ~$30

### UI/UX

- [ ] Fire HD tablets (3×): ~$200
- [ ] Tablet mounts: ~$30
- [ ] Discord bot: $0

**Phase Total:** ~$2,170-4,820

---

## Testing Checklist {#run-testing}

Test against [PRD § Success Metrics](../prd.md#success-metrics).

### Presence

- [ ] Room occupancy accurate in all zones
- [ ] No lights turning off while occupied
- [ ] Graceful transitions between rooms
- [ ] mmWave not triggered by pets/fans

### Energy

- [ ] All circuits reporting correctly
- [ ] Identified at least 1 savings opportunity
- [ ] Dashboards showing useful data
- [ ] Cost tracking matches utility bill

### Voice

- [ ] All HomePods responding to commands
- [ ] Siri shortcuts working reliably
- [ ] Household using voice regularly
- [ ] No "Siri didn't understand" in last week

### Safety

- [ ] Smoke/CO test triggers all alerts
- [ ] Notification reaches all channels
- [ ] Response automations execute correctly
- [ ] Doors unlock on alarm

### Garage

- [ ] Opener controlled from HA/Apple Home
- [ ] Status sensors accurate
- [ ] Automations working without false triggers
- [ ] Manual override always works

### UI/UX

- [ ] Tablets wake on motion
- [ ] Dashboards intuitive for household
- [ ] Guest mode accessible
- [ ] Documentation complete and printed

---

## Success Metrics (End of Run) {#run-success}

Per [PRD § Phase 3 Success Metrics](../prd.md#phase-run).

**Quantitative:**

- [ ] Presence detection accuracy >95%
- [ ] Energy savings identified: 10%+
- [ ] Guest satisfaction: Can use without help
- [ ] System uptime: >99.5%
- [ ] Maintenance: <1 hour/month

**Qualitative:**

- [ ] Household member suggests new automations
- [ ] Household uses voice control naturally
- [ ] Guests compliment setup
- [ ] No regrets about technology choices
- [ ] "Just works" feeling

---

## Phase Completion Checklist {#run-complete}

Per [PRD § Phase Completion Markers](../prd.md#phase-markers):

- [ ] mmWave presence working in all target rooms
- [ ] Tablets deployed and dashboards polished
- [ ] Household documentation printed and distributed
- [ ] 30-day stability achieved
- [ ] Git tag: `run-complete` created

---

## Project Completion Celebration! 🎉

**You've built:**

- Complete smart home automation
- Privacy-first architecture
- Household-friendly interface
- Self-hosted infrastructure
- Expandable foundation

**Skills mastered:**

- Home Assistant configuration
- Network segmentation
- Automation design
- Integration troubleshooting
- UX for smart homes

**What's next?**

See [PRD § Future Expansion Ideas](../prd.md#future):

- Maintain and optimize
- Add features as needed
- Help others on forums
- Share your setup!
- Enjoy your smart home!

---

**Congratulations on completing the 18-month journey!** 🏆
