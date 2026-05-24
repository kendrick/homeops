# WALK Phase: Months 3-9 {#walk}

## Expand Sensing, Add Convenience

**Budget:** ~$1,000
**Timeline:** 6 months
**Status:** Not started (complete Crawl first)

**PRD Reference:** [Phase 2: WALK](../prd.md#phase-walk)

---

## Phase Goals {#walk-goals}

✅ Comprehensive sensor network deployed
✅ Garage climate controlled
✅ Rachio irrigation smart and weather-aware
✅ Apple TV scenes working
✅ Sonos integration (as speakers acquired)
✅ Intelligent notification system
✅ Circadian lighting throughout

---

## Prerequisites {#walk-prerequisites}

Before starting Walk phase, verify Crawl is complete per [PRD § Phase Completion Markers](../prd.md#phase-markers):

- [ ] All switches installed and labeled
- [ ] VLANs tested (can ping correctly, can't ping incorrectly)
- [ ] 5 core automations running reliably
- [ ] Household member has used Siri successfully 3+ times
- [ ] Git tag: `crawl-complete` exists

---

## Month-by-Month Breakdown

### Month 4: Deploy Sensor Network {#month-4}

Follow [PRD § Protocols](../prd.md#protocols) - use Zigbee for all battery-powered sensors.

#### Door/Window Sensors (8-12× Aqara ~$120-180)

**Sensor Selection Criteria:**

Choose Aqara P2 (Zigbee 3.0) for new purchases:
- Better battery life than P1
- Faster response time
- Matter-ready firmware

Priority placement (in order):

- [ ] Front door (security + automation trigger)
- [ ] Back door (security + automation trigger)
- [ ] Garage entry door (presence detection)
- [ ] Bedroom 4 windows (2× - teen sneakout prevention)
- [ ] Ground floor windows (safety - 3-5 sensors)

**Installation:**

Complete [PRD § Before Adding Any Integration](../prd.md#integration-checklist) before pairing.

For each sensor:
- [ ] Clean surface with alcohol
- [ ] Attach sensor to frame, magnet to door/window
- [ ] Pair via ZHA: Settings → Devices → Add Device
- [ ] Name using [PRD § Entity Naming Convention](../prd.md#entity-naming): `binary_sensor.first_front_door`
- [ ] Test: Open door, verify HA state changes immediately

#### Water Leak Sensors (14× Aqara ~$280)

**CRITICAL:** These prevent catastrophic damage. Priority deployment.

Required placements:

- [ ] Under toilets (5 total: 3.5 baths)
  - Master bath toilet
  - Bath 2 toilet
  - Bath 3 toilet
  - Half bath toilet
  - Powder room toilet
- [ ] Under sinks (5 total)
  - Kitchen sink
  - Master bath sink
  - Bath 2 sink
  - Bath 3 sink
  - Laundry sink
- [ ] Dishwasher base
- [ ] Washing machine base
- [ ] HVAC overflow pans (2× if dual system)
- [ ] Water heater base

**Testing Protocol:**

For each sensor:
- [ ] Place sensor in final location
- [ ] Drip water on sensor probes
- [ ] Verify alert triggers within 5 seconds
- [ ] Confirm notification received on phone
- [ ] Dry sensor and verify "clear" state

#### Motion Sensors (5-6× Aqara ~$90-110)

**Sensor Placement Strategy:**

Motion sensors should be placed:
- 7-8 feet high (avoid pets if applicable)
- Aimed at entry points, not windows (avoid false triggers from cars)
- Away from HVAC vents (temperature changes trigger PIR)

Strategic locations (priority order):

- [ ] Office (work presence - tie to circadian lighting)
- [ ] Main hallway (automatic nighttime lighting)
- [ ] Garage entry (lights on when entering house)
- [ ] Pantry (convenience - light on when entering)
- [ ] Master closet (optional - if budget allows)

**Motion → Lighting Automation Pattern:**

```yaml
# File: automations/event_hallway_motion_light.yaml
alias: "Event - Hallway - Motion Light"
description: >
  WHAT: Turn on hallway light when motion detected at night
  WHY: Safety; convenience; no fumbling for switches
  OVERRIDE: Turn light off manually; it will re-trigger on next motion

trigger:
  - platform: state
    entity_id: binary_sensor.first_hallway_motion
    to: 'on'

condition:
  - condition: sun
    after: sunset
    before: sunrise
  - condition: state
    entity_id: group.everyone
    state: 'home'

action:
  - service: light.turn_on
    target:
      entity_id: light.first_hallway
    data:
      brightness_pct: 30
      kelvin: 2200  # Very warm at night
  - delay:
      minutes: 5
  - service: light.turn_off
    target:
      entity_id: light.first_hallway

mode: restart  # Restart timer on new motion
id: event_hallway_motion_light
```

#### Sensor Automations

Complete [PRD § Before Creating Any Automation](../prd.md#automation-checklist) checklist.

**Door/Window Alerts:**

```yaml
# File: automations/security_doors_opened_night.yaml
alias: "Security - Doors - Opened Night"
description: >
  WHAT: Alert if door/window opened after bedtime
  WHY: Security awareness; teen boundary enforcement
  OVERRIDE: Dismiss notification; check camera/sensor

trigger:
  - platform: state
    entity_id:
      - binary_sensor.first_front_door
      - binary_sensor.first_back_door
      - binary_sensor.second_bedroom_4_window_1
      - binary_sensor.second_bedroom_4_window_2
    to: 'on'

condition:
  - condition: time
    after: '22:00:00'
    before: '06:00:00'

action:
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "🚪 {{ trigger.to_state.attributes.friendly_name }} opened at {{ now().strftime('%I:%M %p') }}"
      data:
        push:
          sound:
            name: default
            critical: 1
            volume: 1.0

mode: parallel
id: security_doors_opened_night
```

**Water Leak Alerts (CRITICAL):**

```yaml
# File: automations/safety_water_leak_alert.yaml
alias: "Safety - Water - Leak Alert"
description: >
  WHAT: LOUD multi-channel alert on water detection
  WHY: Prevent catastrophic water damage
  OVERRIDE: None - always alert

trigger:
  - platform: state
    entity_id:
      - binary_sensor.first_kitchen_leak
      - binary_sensor.first_laundry_leak
      - binary_sensor.first_dishwasher_leak
      - binary_sensor.second_master_bath_leak
      - binary_sensor.second_bath_2_leak
      - binary_sensor.second_bath_3_leak
      - binary_sensor.garage_water_heater_leak
      - binary_sensor.first_hvac_leak
      - binary_sensor.second_hvac_leak
    to: 'on'

condition: []  # ALWAYS alert, no conditions

action:
  # Push notification with critical alert
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "🚨 WATER LEAK: {{ trigger.to_state.attributes.friendly_name }}"
      data:
        push:
          sound:
            name: default
            critical: 1
            volume: 1.0
  - service: notify.mobile_app_household_member_iphone
    data:
      message: "🚨 WATER LEAK: {{ trigger.to_state.attributes.friendly_name }}"
      data:
        push:
          sound:
            name: default
            critical: 1
            volume: 1.0
  # TTS announcement (if Sonos available)
  - service: tts.speak
    target:
      entity_id: tts.google_en
    data:
      media_player_entity_id: media_player.living_room
      message: "Warning! Water leak detected in {{ trigger.to_state.attributes.friendly_name }}. Check immediately."
  # Flash lights
  - service: light.turn_on
    target:
      entity_id: all
    data:
      flash: long

mode: parallel
id: safety_water_leak_alert
```

---

### Month 5: Climate Control Expansion {#month-5}

#### Honeywell T6 Pro Integration

See [PRD § Integrations - Medium Priority](../prd.md#integrations-walk) for integration details.

- [ ] Add thermostats to HA
  - Settings → Integrations → Add → Honeywell Home
  - Authorize with Honeywell account
  - Verify both thermostats appear

- [ ] Create climate automations:

**Away Mode:**

```yaml
# File: automations/presence_everyone_away_climate.yaml
alias: "Presence - Everyone - Away Climate"
description: >
  WHAT: Set thermostats to eco mode when everyone leaves
  WHY: Energy savings (don't heat/cool empty house)
  OVERRIDE: Adjust thermostat manually; will reset on arrival

trigger:
  - platform: state
    entity_id: group.everyone
    to: 'not_home'
    for:
      minutes: 30  # Wait to avoid short trips

condition: []

action:
  - service: climate.set_preset_mode
    target:
      entity_id:
        - climate.upstairs
        - climate.downstairs
    data:
      preset_mode: away

mode: single
id: presence_everyone_away_climate
```

**Override Detection:**

```yaml
# File: automations/climate_manual_override_pause.yaml
alias: "Climate - Manual Override - Pause"
description: >
  WHAT: Pause automations for 2 hours if thermostat manually changed
  WHY: Respect manual adjustments; HAF
  OVERRIDE: Trigger "resume" automation manually

trigger:
  - platform: state
    entity_id:
      - climate.upstairs
      - climate.downstairs
    attribute: temperature

condition:
  # Only if changed significantly (not by automation)
  - condition: template
    value_template: >
      {{ (trigger.from_state.attributes.temperature | float -
          trigger.to_state.attributes.temperature | float) | abs > 1 }}

action:
  - service: input_boolean.turn_on
    target:
      entity_id: input_boolean.climate_manual_override
  - delay:
      hours: 2
  - service: input_boolean.turn_off
    target:
      entity_id: input_boolean.climate_manual_override

mode: restart
id: climate_manual_override_pause
```

#### Garage Mini-Split Setup

**Prerequisites:**
- Mini-split physically installed (DIY or contractor)
- Power connected
- Remote control tested

**Integration Steps:**

- [ ] Install Broadlink RM4 Pro IR blaster (~$40)
  - Mount within line-of-sight of mini-split
  - Connect to IoT VLAN WiFi

- [ ] Add to HA
  - Settings → Integrations → Add → Broadlink
  - Follow pairing instructions

- [ ] Learn remote commands
  - Settings → Devices → Broadlink → Learn Command
  - Commands needed:
    - Power On/Off
    - Temp Up/Down
    - Mode: Cool/Heat/Auto
    - Fan speed

- [ ] Create climate automations:

```yaml
# File: automations/climate_garage_hot.yaml
alias: "Climate - Garage - Hot"
description: >
  WHAT: Turn on garage cooling when temp >85°F
  WHY: Protect equipment; comfortable workshop
  OVERRIDE: Turn mini-split off manually

trigger:
  - platform: numeric_state
    entity_id: sensor.garage_temperature
    above: 85

condition:
  - condition: state
    entity_id: cover.garage_door
    state: 'closed'

action:
  - service: remote.send_command
    target:
      entity_id: remote.garage_broadlink
    data:
      command: cool_72

mode: single
id: climate_garage_hot
```

---

### Month 5-6: Rachio Irrigation Integration {#month-5-6}

See [PRD § Integrations - Medium Priority](../prd.md#integrations-walk).

#### Setup

- [ ] Install Rachio 3 controller
  - Mount near existing controller location
  - Wire existing zones
  - Add new drip zones:
    - Trees drip zone (new)
    - Garden drip zone (25 SF, new)

- [ ] Add to HA
  - Settings → Integrations → Add → Rachio
  - Authorize with Rachio account
  - Verify all zones appear

- [ ] Enable weather intelligence
  - Rachio app → Weather Intelligence Plus
  - Enable: Rain Skip, Freeze Skip, Wind Skip

- [ ] Configure seasonal adjust
  - Set for Fort Worth, TX climate
  - Adjust for clay soil (slower absorption)

#### Rachio Automations

```yaml
# File: automations/irrigation_wind_pause.yaml
alias: "Irrigation - Wind - Pause"
description: >
  WHAT: Skip watering if winds >15mph
  WHY: Protect seedlings; water efficiency
  OVERRIDE: Run zone manually from Rachio app

trigger:
  - platform: state
    entity_id: switch.rachio_garden_zone
    to: 'on'

condition:
  - condition: numeric_state
    entity_id: sensor.openweathermap_wind_speed
    above: 15

action:
  - service: switch.turn_off
    target:
      entity_id: switch.rachio_garden_zone
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "🌬️ Garden watering skipped - wind {{ states('sensor.openweathermap_wind_speed') }} mph"

mode: single
id: irrigation_wind_pause
```

---

### Month 6-7: Entertainment Integration {#month-6-7}

#### Apple TV Automations

See [PRD § Automation Patterns](../prd.md#automation-patterns) for good automation design.

**Living Room Movie Mode:**

```yaml
# File: automations/event_livingroom_appletv_movie.yaml
alias: "Event - Living Room - Apple TV Movie"
description: >
  WHAT: Dim lights when movie starts, brighten on pause
  WHY: Cinema experience; convenience
  OVERRIDE: Turn lights on/off manually

trigger:
  - platform: state
    entity_id: media_player.living_room_apple_tv
    to: 'playing'
    id: playing
  - platform: state
    entity_id: media_player.living_room_apple_tv
    to: 'paused'
    id: paused
  - platform: state
    entity_id: media_player.living_room_apple_tv
    to: 'idle'
    for:
      minutes: 5
    id: stopped

condition:
  - condition: sun
    after: sunset

action:
  - choose:
      - conditions:
          - condition: trigger
            id: playing
        sequence:
          - service: light.turn_on
            target:
              entity_id: light.first_family_room
            data:
              brightness_pct: 10
              kelvin: 2200
      - conditions:
          - condition: trigger
            id: paused
        sequence:
          - service: light.turn_on
            target:
              entity_id: light.first_family_room
            data:
              brightness_pct: 40
              kelvin: 2700
      - conditions:
          - condition: trigger
            id: stopped
        sequence:
          - service: light.turn_on
            target:
              entity_id: light.first_family_room
            data:
              brightness_pct: 80
              kelvin: 3000

mode: single
id: event_livingroom_appletv_movie
```

#### Sonos Integration

Review [PRD § Sonos Integration Issues](../prd.md#sonos-issues) before setting up.

- [ ] Add official Sonos integration to HA
  - Settings → Integrations → Add → Sonos
  - Devices should auto-discover

- [ ] Configure speakers as media players

- [ ] Test TTS announcements
  - Developer Tools → Services → tts.speak
  - Verify [PRD § Sonos TTS Workaround](../prd.md#sonos-issues) if first word cuts off

- [ ] Create music scenes
  ```yaml
  # scenes/music_dinner.yaml
  alias: "Music - Dinner"
  entities:
    media_player.living_room:
      state: playing
      source: "Dinner Jazz"
      volume_level: 0.3
  ```

**Note:** Sonos can be temperamental. Use cloud integration first; local options (like SoCo) are more complex.

---

### Month 8-9: Notifications & Advanced Automations {#month-8-9}

#### Notification Categories

Categorize all notifications per [PRD § Automation Philosophy](../prd.md#automation-philosophy):

**Critical (immediate push + TTS + visual):**
- Water leak
- Door/window unexpected at night
- Smoke/CO (future)

**Important (push notification):**
- Dryer finished
- Garage door left open >15 min
- Someone home unexpectedly

**Informational (silent or morning digest):**
- Watering started/finished
- Daily automation summary

#### Actionable Notifications

```yaml
# File: automations/notify_front_door_unlocked.yaml
alias: "Notify - Front Door - Unlocked"
description: >
  WHAT: Ask if door should be locked when left unlocked
  WHY: Security reminder without annoying auto-lock
  OVERRIDE: Ignore notification

trigger:
  - platform: state
    entity_id: lock.first_front_door
    to: 'unlocked'
    for:
      minutes: 10

condition:
  - condition: time
    after: '21:00:00'
    before: '07:00:00'

action:
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "🔓 Front door unlocked for 10 min. Lock it?"
      data:
        actions:
          - action: "LOCK_FRONT"
            title: "Lock Door"
          - action: "IGNORE"
            title: "Leave Open"

mode: single
id: notify_front_door_unlocked
```

```yaml
# File: automations/notify_action_lock_front.yaml
alias: "Notify Action - Lock Front"
trigger:
  - platform: event
    event_type: ios.notification_action_fired
    event_data:
      actionName: "LOCK_FRONT"

action:
  - service: lock.lock
    target:
      entity_id: lock.first_front_door
  - service: notify.mobile_app_kendrick_iphone
    data:
      message: "✅ Front door locked."

mode: single
id: notify_action_lock_front
```

#### Circadian Lighting

- [ ] Install Adaptive Lighting integration
  - HACS → Integrations → Adaptive Lighting
  - Add via Settings → Integrations

- [ ] Configure for all dimmable lights

```yaml
# configuration.yaml
adaptive_lighting:
  - name: "Default"
    lights:
      - light.first_kitchen_island
      - light.first_family_room
      - light.second_bedroom_2
      - light.second_bedroom_3
      - light.second_bedroom_4
      - light.first_owner_bedroom
    min_brightness: 20
    max_brightness: 100
    min_color_temp: 2200  # Very warm at night
    max_color_temp: 5500  # Cool white at noon
    sleep_brightness: 10
    sleep_color_temp: 2000
    sunrise_offset: 0
    sunset_offset: 0
    transition: 60  # 60 second transitions
    adapt_delay: 5  # Wait 5s after light on
```

Schedule:
- Morning (6-9 AM): Gradual warm → cool (energizing)
- Midday (9 AM - 5 PM): Cool white (productive)
- Evening (5-9 PM): Gradual cool → warm (relaxing)
- Night (9 PM+): Very warm, dim (sleep-friendly)

---

## Shopping List {#walk-shopping}

### Sensors

- [ ] Aqara door/window sensors (10×): ~$150
- [ ] Aqara water leak sensors (14×): ~$280
- [ ] Aqara motion sensors (6×): ~$110

### Climate

- [ ] Broadlink RM4 Pro: ~$40

### Entertainment

- [ ] (Sonos speakers purchased separately)

### Services

- [ ] Nabu Casa (ongoing): $6.50/month

**Phase Total:** ~$580 + Nabu Casa

**Note:** Budget shows ~$580 vs PRD's ~$1,000 allocation. Remaining $400+ available for:
- Additional sensors if needed
- Replacement devices
- Unexpected integration hardware
- Starting Run phase purchases early

---

## Testing Checklist {#walk-testing}

Test against [PRD § Success Metrics](../prd.md#success-metrics).

### Sensors

- [ ] All sensors paired and reporting
- [ ] Battery levels monitored (add battery alerts)
- [ ] No false positive leak alerts in 2 weeks
- [ ] Door/window notifications working
- [ ] Motion sensors not triggering on pets/HVAC

### Climate

- [ ] Thermostats responding to automations
- [ ] Garage mini-split controlled remotely
- [ ] Away mode working correctly
- [ ] Manual override detection working

### Irrigation

- [ ] Rachio skipped watering due to rain (at least once)
- [ ] Garden zone watering on schedule
- [ ] Weather intelligence working
- [ ] Manual overrides functional from app

### Entertainment

- [ ] Apple TV scenes triggering correctly
- [ ] Sonos playback controllable from HA
- [ ] TTS announcements working (no cutoff)
- [ ] No integration breakage over 2 weeks

### Notifications

- [ ] Critical alerts arrive <30 seconds
- [ ] No notification spam (categorized correctly)
- [ ] Actionable notifications work
- [ ] Household not annoyed by alerts

---

## Success Metrics (End of Walk) {#walk-success}

Per [PRD § Phase 2 Success Metrics](../prd.md#phase-walk).

- [ ] Zero false positive leak alerts
- [ ] Rachio weather intelligence saves water (documented)
- [ ] Notification latency <30 seconds for critical
- [ ] Household uses Apple TV automations regularly
- [ ] No "smart home is annoying" complaints

---

## Phase Completion Checklist {#walk-complete}

Per [PRD § Phase Completion Markers](../prd.md#phase-markers):

- [ ] All sensors deployed and reporting
- [ ] Climate automations running
- [ ] Rachio weather intelligence verified
- [ ] Notifications categorized and non-spammy
- [ ] Git tag: `walk-complete` created

---

## Next Phase Preview {#walk-next}

**Run phase focus:** See [PRD § Phase 3: RUN](../prd.md#phase-run)

- mmWave presence sensors (stationary detection)
- Smart window coverings
- Whole-home energy monitoring
- HomePod voice control
- Wall-mounted tablets
- Guest-friendly dashboards

---

**Next up: RUN phase - Perfect the experience!** 🏃‍♂️
