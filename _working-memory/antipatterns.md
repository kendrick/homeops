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

## 2026-05-23 — Don't pair Forgejo + Claude Code on a single shared LXC

**Tried:** A shared `docker01` LXC was proposed to host both Forgejo (with Docker + Postgres) and Claude Code under one roof, on Tailscale.

**What broke:** Long-running Claude Code agents with broad filesystem permissions sitting adjacent to the canonical git data store is a bad blast radius. If the agent goes sideways, it can touch Forgejo's bind-mounts directly.

**Why we backed out:** Separated into CT 100 (Forgejo, native LXC, git-host-only) and CT 101 (Claude Code dev, native LXC, agent work only). Cheap on Proxmox; clean separation of concerns. See ADR-010.

**Don't suggest:** Co-tenanting AI agents with primary data stores on a single container, even on a "trusted" homelab network.
