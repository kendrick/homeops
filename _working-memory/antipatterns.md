# Antipatterns

<!-- Negative knowledge. Things tried (or seriously considered) that didn't pan out, -->
<!-- captured so agents and humans don't re-litigate closed loops. Append-only.       -->
<!--                                                                                   -->
<!-- Format:                                                                           -->
<!-- ## YYYY-MM-DD — [Short title in imperative voice — what to avoid]                -->
<!-- **Tried:** What was attempted (or proposed in conversation and rejected)         -->
<!-- **What broke:** Observed failure mode or anticipated failure                     -->
<!-- **Why we backed out:** Root cause or strongest objection                         -->
<!-- **Don't suggest:** Specific things agents should not re-propose                  -->

## 2026-05-23 — Don't run Forgejo in Docker on a privileged LXC

**Tried:** Initial plan called for `docker01` LXC (privileged, Docker installed) running Forgejo + Postgres via docker-compose, with Tailscale + Claude Code also co-tenanted on the same container.

**What broke:** Stacks Docker on top of Proxmox's container layer for no benefit — duplicates the lifecycle/snapshot/backup primitives Proxmox already provides. The privileged-LXC requirement for Docker punches through unprivileged-LXC isolation as the default. Co-tenanting Claude Code + Forgejo on one container creates bad blast radius (long-running agent permissions adjacent to the git data store).

**Why we backed out:** Proxmox-native pattern (one unprivileged LXC per service, native binary install) is lighter, more isolated, and matches the platform's intent. See ADR-007 (Forgejo as native LXC), ADR-009 (native-LXC default), ADR-010 (separate dev LXC for Claude Code).

**Don't suggest:** Docker-in-privileged-LXC as the default deployment pattern for a new homelab service. If Docker is genuinely required (compose-only app), spin up a dedicated Docker LXC for those apps specifically, not as the foundation.

---

## 2026-05-23 — Don't pre-write exhaustive step-by-step procedures in issue bodies

**Tried:** Original 45 CRAWL issues each contained detailed implementation procedures (specific button names, version numbers, image tags, UI navigation paths) written 6 months before execution.

**What broke:** ~70% of the per-step content would be stale by execution time — vendor UIs change, package versions bump, image tags rotate, in-the-moment decisions invalidate assumptions. Following the recipe felt like working through outdated tutorial content rather than thinking.

**Why we backed out:** Replanned to thin-brief issues (problem / why now / acceptance criteria / constraints / references) with execution planning happening in-session via plan mode against the current state of the world. The issue is the spec; the plan is regenerated each time.

**Don't suggest:** Filling out long step-by-step procedures inside GitHub issue bodies. Capture acceptance criteria; let the implementation plan emerge from a planning session at execution time.

---

## 2026-05-24 — Don't propose Asus ROG Rapture (or AsusWRT-based gaming routers) for homelab routing

**Tried:** Considered the Asus ROG Rapture line (GT-AX / GT-BE series, $400-1000+) as an alternative to the GL.iNet Flint 2 ($180) for the CRAWL router slot per ADR-003 (VLAN segmentation) and ADR-008 (Tailscale).

**What broke:** ROG Rapture is built for gaming-grade WiFi prioritization, not homelab use. Stock AsusWRT has shallow VLAN support (mostly a single "guest network" toggle); real VLAN segmentation needs Merlin firmware plus CLI work. No built-in Tailscale; Asus would push that onto a separate device. AdGuard-style filtering also needs Merlin. The premium is $200-800+ over Flint 2 for WiFi performance the homelab use case doesn't actually need.

**Why we backed out:** Flint 2 has native VLAN UI that matches ADR-003, built-in Tailscale that matches ADR-008, built-in AdGuard Home, OpenWrt firmware (the lingua franca of homelab routers), and costs less than half. ROG Rapture's wins (WiFi range, gaming QoS, polished mobile app) don't intersect with what CRAWL needs.

**Don't suggest:** Asus ROG Rapture or any AsusWRT-based gaming router as a router replacement in this project. If WiFi performance turns into a real problem later, the answer is "add a UniFi AP" not "swap to a gaming router." If routing/firewall capability becomes the bottleneck, the answer is "graduate to Mikrotik RB5009 or Protectli + OPNsense" not Asus.

---

## 2026-05-23 — Don't trust `core.hooksPath` to survive `rm -rf .git`

**Tried:** Pre-push PII hook wired via `git config core.hooksPath scripts/git-hooks`. Then Phase E did `rm -rf .git && git init` for the clean-history repo recreate. First push to the new public repo went through with no hook firing.

**What broke:** `core.hooksPath` lives in `.git/config`. Re-init wipes the config. The hook script was still on disk and executable, but the new `.git/config` had no `core.hooksPath` setting, so git defaulted to `.git/hooks/` (which is empty after init). Push gate was silently absent.

**Why we backed out:** Caught only because the user noticed the hook didn't fire and asked. Tracked content was already verified PII-clean pre-push (lucky), so nothing leaked. If content had been dirty, it would have shipped to a public repo with no warning.

**Don't suggest:** Relying on `core.hooksPath` (or any `.git/config` setting) to persist across `git init` / re-init / clone. After any fresh init: immediately run `git config core.hooksPath scripts/git-hooks` (already in `conventions.md` as `required`). For Phase-E-style recreates specifically, the recreate command sequence must include the `git config` line as a non-optional step, not as a follow-up.

---

## 2026-05-23 — Don't pair Forgejo + Claude Code on a single shared LXC

**Tried:** A shared `docker01` LXC was proposed to host both Forgejo (with Docker + Postgres) and Claude Code under one roof, on Tailscale.

**What broke:** Long-running Claude Code agents with broad filesystem permissions sitting adjacent to the canonical git data store is a bad blast radius. If the agent goes sideways, it can touch Forgejo's bind-mounts directly.

**Why we backed out:** Separated into CT 100 (Forgejo, native LXC, git-host-only) and CT 101 (Claude Code dev, native LXC, agent work only). Cheap on Proxmox; clean separation of concerns. See ADR-010.

**Don't suggest:** Co-tenanting AI agents with primary data stores on a single container, even on a "trusted" homelab network.

---

## 2026-05-25 — Don't host homeops on a Mac (Studio or otherwise)

**Tried:** Considered running the homelab stack (Proxmox, HA OS, Forgejo, Claude Code dev, future Jellyfin / Immich / Paperless) on an Apple Silicon Mac Studio instead of the Intel mini-ITX PC, motivated by the maintainer preferring Macs elsewhere.

**What broke:**

- HA OS has no clean Apple Silicon installation path. The standard recommendation remains "HA OS in a VM on Linux/Proxmox." HA Container on macOS via OrbStack/Colima works but loses add-on support; HA Core direct on macOS is unsupported and breaks on every release.
- Proxmox doesn't run on Apple Silicon. Proxmox is Debian + KVM on x86. Asahi Linux exists for Apple Silicon but isn't a Proxmox target.
- LXC isn't a thing on macOS. Going all-Mac forces a Docker-everywhere architecture, retroactively killing ADR-009 (native LXC over Docker).
- macOS power management fights homelab uptime. Sleep behavior, forced reboots for OS updates, energy-saver background-process suspension — all designed for a workstation, not a 24/7 service host.
- ARM-only image availability is patchy. Some homelab Docker images don't have ARM builds; others are flaky.
- Cost: a comparable-spec Mac Studio is several multiples of a refreshed mini-ITX PC or mini-PC.

**Why we backed out:** The Mac is a great workstation and a great Apple-ecosystem appliance. It is not a Linux container host. Forcing it into that role requires retconning every architectural decision we've made (LXC-native per ADR-009, HA OS in VM per ADR-001 + CRAWL-05, Proxmox as hypervisor) and fighting macOS at every turn.

**Don't suggest:**

- Hosting Proxmox, HA OS, or the LXC-based homelab services on a Mac (any model).
- Replacing the Intel PC with a Mac as the primary homelab host.
- Reaching for OrbStack / Colima / Docker Desktop on macOS as the homelab foundation.

**What IS reasonable** (not an antipattern, just out of scope for this entry):

- The Mac stays the maintainer's workstation (Claude Code, SSH, browsers, IDE).
- A Mac mini as a complementary Apple-ecosystem appliance alongside the PC homelab — HomeKit Home Hub workloads, native iCloud Photos export, Plex Server with Apple Silicon performance, Apple TV automation helpers. Two-box pattern, not replacement. Worth considering at WALK or RUN, not CRAWL.

---

## 2026-06-05 — Don't pad `activeContext.md` with items needed weeks away

**Tried:** Early CRAWL-01 planning surfaced a "BOM (block 1a; long lead time, order first)" section in `activeContext.md` listing the Sonoff Zigbee dongle, TP-Link managed switch, GL.iNet Flint 2 router, USB extension, and label maker. Reasoning at the time: "long lead time, start the shipping clock now so the gear is on hand when you need it."

**What broke:** When CRAWL-01 actually started, the maintainer realized none of those BOM items are needed until CRAWL-09 (Zigbee) and CRAWL-10 (network rebuild) — six-plus sessions out at weekend pace. The "long lead time" framing was correct in spirit but wrong in scale: 2-7 days of shipping doesn't bottleneck a workflow that's 5-6+ weeks from needing the gear. Padding activeContext with items that far out turned it into an archive of what-was-relevant-before rather than a queue of what's-next.

**Why we backed out:** activeContext's hard rule is "queue, not archive" (≤20 non-empty lines). Items further out than the next 1-2 sessions don't earn a slot. They belong in the issue body (where the hardware now lives under `## Hardware needed` in CRAWL-09 / 10 / 11 / 12), not in the maintainer's top-of-mind queue. The BOM section was deleted from activeContext on 2026-06-05.

**Don't suggest:**
- Listing long-lead-time hardware in `activeContext.md` when the use is more than 1-2 sessions out.
- "Order now because shipping takes a few days" reasoning without checking how many sessions away the actual need is.
- When proposing orders, anchor on session distance (not calendar shipping time). Recommend ordering only when the maintainer is ~1-2 sessions from needing the gear (e.g., after CRAWL-07 completes, order for CRAWL-09 / 10).
