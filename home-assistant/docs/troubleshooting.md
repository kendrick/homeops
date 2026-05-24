# Troubleshooting Guide

Quick fixes for common issues. For each problem: symptoms, cause, and solution.

---

## Home Assistant Won't Start

**Symptoms:**
- Can't access http://homeassistant.local:8123
- Page times out or shows "connection refused"

**Possible Causes & Solutions:**

1. **Power/hardware issue**
   - Check PC is powered on
   - Check network cable connected
   - Try accessing via IP address instead of hostname

2. **Corrupted installation**
   - Boot into safe mode (hold power during boot)
   - Restore from backup
   - Worst case: Fresh install and restore config

3. **Network issue**
   - Check VLAN configuration (HA on VLAN 30)
   - Verify firewall rules allow access from VLAN 1
   - Try accessing from same VLAN

---

## Zigbee Device Won't Pair

**Symptoms:**
- Device doesn't appear in ZHA after pairing mode
- Pairing times out

**Solutions:**

1. **Move coordinator away from interference**
   - Use USB extension cable
   - Keep away from USB 3.0 ports
   - Distance from WiFi router

2. **Reset device properly**
   - Hold reset button 10+ seconds
   - Some devices: Remove battery, wait 30 sec, reinsert
   - Check device manual for specific reset procedure

3. **Check Zigbee mesh**
   - Need powered devices as routers
   - Battery devices won't extend mesh
   - Add a powered switch nearby

4. **Coordinator at capacity**
   - ZHA supports ~40-50 direct devices
   - Need router devices to extend network
   - Check coordinator firmware is updated

---

## Light Not Responding

**Symptoms:**
- Switch shows "unavailable" in HA
- Light doesn't turn on/off from HA
- Physical switch works fine

**Solutions:**

1. **Check power**
   - Breaker tripped?
   - Power outage reset the switch?
   - Try toggling breaker

2. **Zigbee mesh issue**
   - Device too far from coordinator/routers
   - Check ZHA visualization (Settings → Integrations → ZHA → Visualize)
   - Add router device between coordinator and problem switch

3. **Re-pair device**
   - Remove from HA (ZHA → Devices → Remove)
   - Factory reset switch
   - Re-pair and reconfigure

4. **Check automations**
   - Conflicting automation turning it back off?
   - Check automation traces (Settings → Automations → [automation] → Trace)

---

## Lock Won't Connect / Shows Offline

**Symptoms:**
- Lock appears offline in HA
- Can't control from app
- Physical operation works fine

**Solutions:**

1. **WiFi signal strength**
   - Check lock is within WiFi range
   - Move closer to access point
   - Consider adding WiFi extender or mesh node

2. **VLAN/firewall issue**
   - Verify lock is on IoT VLAN (VLAN 10)
   - Check firewall allows IoT → HA server (VLAN 30)
   - Verify DNS resolution works on IoT VLAN

3. **Battery low**
   - Replace batteries (locks drain quickly)
   - Low battery = WiFi radio shuts down first

4. **Integration broken**
   - Check Kwikset integration in HA
   - May need to re-authenticate
   - Check Kwikset cloud status (even though local, uses cloud for initial setup)

---

## Automation Not Triggering

**Symptoms:**
- Automation exists but doesn't run when expected
- No errors shown

**Solutions:**

1. **Check trigger conditions**
   - Use Developer Tools → Events to watch for trigger
   - Verify entity names are correct (typos!)
   - Check state values match (case-sensitive)

2. **Check time zone**
   - HA time zone set correctly?
   - Server time matches real time?
   - `date` command in Terminal to verify

3. **Check conditions**
   - Automation triggered but conditions not met?
   - View automation traces (Settings → Automations → Trace)
   - Conditions must ALL be true

4. **Disabled automation**
   - Check automation is enabled (toggle at top)
   - Was it disabled by error?

5. **YAML syntax error**
   - Check Configuration → Server Controls → Check Configuration
   - Look for YAML indentation errors (2 spaces, not tabs!)

---

## Apple Home Not Syncing

**Symptoms:**
- Devices missing from Home app
- "No Response" in Home app
- Changes in HA don't reflect in Home app

**Solutions:**

1. **Restart Nabu Casa integration**
   - Settings → Integrations → Home Assistant Cloud
   - Disable → wait 30 sec → Enable

2. **HomeKit accessory limit**
   - Apple Home max 150 accessories
   - Check count in Home app
   - Remove unused devices

3. **Force refresh**
   - Open Home app → Home settings → Hubs & Bridges
   - Remove HA → Re-add
   - Wait 5 minutes for sync

4. **Check exposed entities**
   - Settings → Integrations → Home Assistant Cloud → Apple Home
   - Verify devices are checked to expose
   - Some entity types not supported (check HA docs)

---

## Presence Detection Inaccurate

**Symptoms:**
- "Leaving home" triggers when still home
- "Arriving home" doesn't trigger
- Random state changes

**Solutions:**

1. **Phone GPS issues**
   - Check HA Companion app location permissions (Always)
   - iOS: Settings → HA Companion → Location → Always
   - Background refresh enabled?

2. **Zone size too small**
   - Increase home zone radius (default 100m → try 150m)
   - Settings → Areas & Zones → Home → Edit

3. **Battery optimization**
   - HA Companion app excluded from battery optimization
   - iOS: Handles automatically
   - Check app is sending location updates

4. **Multiple devices**
   - Use device_tracker groups for reliability
   - "Person" entity combines multiple trackers
   - Set person's primary device tracker

---

## Sonos Integration Broken

**Symptoms:**
- Sonos speakers not discovered
- "Unavailable" status
- Can't control playback

**Solutions:**

1. **Expected issue (Sonos updates frequently break integration)**
   - Check HA community forums for others with same issue
   - Wait for HA update (usually fixed within days)
   - Temporary: Control via Sonos app

2. **Network discovery issue**
   - Sonos must be on same network as HA (or VLANs must allow UPnP)
   - Enable UPnP/SSDP on router if needed
   - Check firewall not blocking discovery

3. **Re-add integration**
   - Remove Sonos integration
   - Restart HA
   - Re-add (should auto-discover)

4. **Use cloud integration as fallback**
   - Official Sonos integration more reliable than local
   - Sacrifices some local control for stability

---

## High CPU / Memory Usage on HA Server

**Symptoms:**
- HA sluggish
- Automations delayed
- Web interface slow

**Solutions:**

1. **Check what's using resources**
   - Settings → System → System Health
   - Developer Tools → Statistics
   - SSH: `top` command

2. **Database too large**
   - Check size: `ls -lh /config/home-assistant_v2.db`
   - If >1GB, purge old data:
     - Configuration → Recorder → Purge
   - Reduce retention period (default 10 days)

3. **Too many history items**
   - Exclude noisy sensors from recorder
   - Configuration.yaml:
     ```yaml
     recorder:
       exclude:
         domains:
           - sun
           - sensor.time
     ```

4. **Add-on consuming resources**
   - Settings → Add-ons
   - Check CPU/memory per add-on
   - Disable unused add-ons

---

## Network Issues (Can't Access Devices)

**Symptoms:**
- IoT devices unreachable from HA
- Can ping IP but can't control device

**Solutions:**

1. **VLAN misconfiguration**
   - Verify HA server on VLAN 30
   - Verify IoT devices on VLAN 10
   - Check firewall rules allow VLAN 10 → VLAN 30

2. **DNS issues**
   - IoT devices can't resolve hostnames?
   - Set static DNS on IoT VLAN (8.8.8.8, 1.1.1.1)
   - Or point to local DNS server

3. **IP address changed**
   - DHCP lease expired, device got new IP
   - Use DHCP reservations for IoT devices
   - Set static IPs in router

4. **Firewall blocking**
   - Check router firewall logs
   - Temporarily disable firewall to test
   - Add specific allow rules

---

## Remote Access Not Working

**Symptoms:**
- Can't access HA from outside home network
- Nabu Casa URL times out

**Solutions:**

1. **Nabu Casa subscription lapsed**
   - Check subscription status
   - Renew if expired

2. **HA server offline**
   - Check HA is running on local network
   - Server powered on? Network connected?

3. **Internet connection issue**
   - Home internet down?
   - Router rebooted and need to wait for tunnel to re-establish?

4. **Nabu Casa service outage**
   - Check https://status.nabucasa.com
   - Check HA community forums
   - Wait for service restoration

---

## Getting Help

**When asking for help:**

1. **Check HA logs first**
   - Settings → System → Logs
   - Look for errors related to your issue
   - Copy relevant error messages

2. **Search community**
   - Home Assistant community forums
   - Reddit r/homeassistant
   - Search your exact error message

3. **Provide details:**
   - HA version
   - Integration version
   - Device make/model
   - Error logs
   - What you've tried

4. **Don't just say "it's broken":**
   - ❌ "My lights don't work"
   - ✅ "My Inovelli switches show 'unavailable' in HA after power outage. ZHA logs show 'device_ieee not in database'. Already tried re-pairing."

---

**Remember: Most issues have been encountered before. Search first, ask second.** 🔍
