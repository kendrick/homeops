# Conventions

<!-- PolicyRule rows: each carries an enforcement level. -->
<!-- required:    agent must respect at generation time (hard rule) -->
<!-- recommended: agent should follow unless a documented Exception applies -->
<!-- advisory:    surface as context; doesn't bind behavior -->

## Operational discipline

- `required` — **Manual overrides for all smart fixtures must work with HA offline.** Physical switches/locks/etc. retain native function even when the brain is down. _Why: zero-tolerance for "smart home broke the house" failure modes._
- `required` — **No `git push` without the `pre-push` hook passing.** `scripts/git-hooks/pre-push` is wired via `git config core.hooksPath scripts/git-hooks`. Override (`--no-verify`) only for confirmed false positives. _Why: irreversibility of leaked PII once on a public GitHub repo._
- `required` — **After any `git init` (fresh init, re-init, or clone), immediately run `git config core.hooksPath scripts/git-hooks`.** `core.hooksPath` lives in `.git/config` and is wiped by re-init. See [antipatterns.md](antipatterns.md) entry from 2026-05-23. _Why: the pre-push PII gate is silently absent without this; one re-init can ship dirty content to a public repo before anyone notices._
- `required` — **No `git commit` by automated agents.** Stage + propose message + pause for human. _Why: maintainer retains final review/authorship of every commit._
- `required` — **Closing an issue that adds infrastructure → update `inventory.md` in the same commit.** Definition of done; the `Stop` hook flags drift. _Why: inventory is the durable snapshot of reality; commits without inventory churn cause silent rot._
- `required` — **Making an architectural choice in-session → write/draft an ADR before merging the work.** The `Stop` hook drafts where possible; the human approves. _Why: choices made in chat without ADRs become tribal knowledge that future sessions can't reason over._
- `required` — **Touching `docs/decisions.md` → regenerate `_working-memory/decisionLog.md` in the same commit.** The `Stop` hook does this automatically; if you edit ADRs by hand, run `scripts/regen-decision-log.sh`. _Why: the log is derived; double-maintenance is a known anti-pattern._

## Architecture defaults

- `recommended` — **Prefer native LXC over Docker for homelab services on Proxmox.** Docker only when the app ships compose-only and porting is genuinely impractical. _Why: Proxmox primitives (snapshots, vzdump, lifecycle) already cover the container-management surface. See ADR-009._
- `recommended` — **Default to Zigbee over WiFi for new smart-home devices** unless a documented exception applies (specific feature requires WiFi, no Zigbee equivalent exists, etc.). _Why: local control, mesh resilience, no cloud dependency. See ADR-002._
- `recommended` — **Off-network access via Tailscale, not public ingress.** New services land on the tailnet; no port-forwarding or public DNS unless absolutely required. _Why: zero attack surface beyond the tailnet. See ADR-008._

## Workflow

- `recommended` — **Plan execution steps in-session via plan mode; don't pre-write procedural detail in issue bodies.** Issue bodies stay as thin briefs (problem / why now / acceptance criteria / constraints / references). _Why: pre-written steps rot fast — vendor UI changes, version bumps, in-the-moment decisions invalidate ~70%._
- `recommended` — **Before proposing an architectural choice, grep `alternatives_considered` across existing ADRs for prior rejections.** If the option was already rejected, surface the prior reasoning rather than re-proposing it. _Why: re-litigation is a known anti-pattern; structured frontmatter is what prevents it._
- `recommended` — **New automation tested in notification-only mode for ≥48h before action-enabled.** Replace `service:` with `notify.mobile_app_*` until you've watched it fire correctly under realistic conditions. _Why: false-positive automations erode HAF fast._
- `recommended` — **Parallelize independent work via batched tool calls or background agents.** Don't serialize obviously-independent edits. _Why: throughput; user explicit preference._
- `recommended` — **Before creating any new file, consult the placement table in `AGENTS.md` (under "Where new content goes").** If the file's purpose doesn't match a row, ask before writing rather than guessing a location. _Why: the `home-assistant/` subdirectory drifted into a misnomer because nobody asked "is this still the right home?" at write time; the placement table is the write-time forcing function that prevents recurrence._
- `advisory` — **Entity naming follows `{domain}.{floor}_{room}_{fixture}`** (e.g., `light.second_bedroom_2_ceiling`). See `networkContracts.md` for the full convention.
- `advisory` — **Snapshot before HA OS or LXC service upgrades.** Proxmox snapshots are instant; rollback is free.
