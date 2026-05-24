---
name: start-issue
description: |
  Generate a session brief for a GitHub issue before starting work. Pulls the issue, surfaces the ADRs / conventions / antipatterns / network contracts in play, the AC, and the non-goals, so a returning maintainer is re-grounded in the project's intended path before drafting an implementation plan. Especially useful after a long absence (weeks or months) when convention drift is most likely.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# start-issue

When the user types `/start-issue N`, this is the ritual to run before any implementation work on issue #N. The goal: get the rules that apply to _this specific work_ in front of the human, so a long-absence return doesn't drift from what's already been decided.

This skill does NOT generate the implementation plan itself. After the brief is in front of the human, plan mode takes over for that.

## Procedure

### 1. Read the always-on context

Read these files in order:

- `_working-memory/activeContext.md` (the queue, what's current)
- `_working-memory/projectOverview.md` (what the project is)

If activeContext.md doesn't exist (e.g., gitignored on a fresh clone), say so and proceed without it.

### 2. Pull the issue

```
gh issue view N --json number,title,body,labels,createdAt
```

If `gh issue view` fails (issue closed, doesn't exist, no auth), surface the error and stop. Don't fabricate the issue body.

### 3. Identify what's "in play" for this work

From the issue body, surface:

**ADRs referenced.** Grep the body for `ADR-NNN` patterns. For each match, read the corresponding section in `docs/decisions.md` (anchor `#adr-nnn`) and surface the `decision_outcome` line from the frontmatter. If the issue body doesn't cite ADRs but the work obviously touches an architectural area (e.g., network → ADR-003; Forgejo / homelab → ADR-007, ADR-009; Tailscale → ADR-008; HA → ADR-001; switches → ADR-005; locks → ADR-006), surface those proactively with a note that you inferred them.

**Convention rules that bind this work.** Read `_working-memory/conventions.md`. Surface every `required` rule (these always apply). Then surface `recommended` rules whose topic matches the issue's domain (heuristic on issue title + labels + body keywords). Skip `advisory` unless explicitly relevant. Show each rule's enforcement level so the human can tell what's binding.

**Antipatterns to avoid.** Read `_working-memory/antipatterns.md`. Any entry whose `Don't suggest` lever touches the issue's domain → surface it.

**Network / protocol contracts.** If the issue touches entity naming, VLAN assignment, IP plan, CT/VM ID allocation, or device protocol selection, read the relevant section of `_working-memory/networkContracts.md` and surface it.

### 4. Long-absence check

```
git log -1 --format=%ct
```

Compute days since the last commit:

```
days=$(( ($(date +%s) - $(git log -1 --format=%ct)) / 86400 ))
```

- < 7 days: no banner
- 7-29 days: gentle note ("It's been X days; conventions and antipatterns haven't changed but worth a glance.")
- 30-89 days: stronger warning ("It's been X days. Recommend reading conventions.md and antipatterns.md fully, not just the rules cited below, before drafting the plan.")
- 90+ days: hard warning ("It's been X days. The project may have drifted significantly. Recommend running `bash scripts/run-audit.sh` BEFORE any implementation work to surface drift, then re-read conventions.md and antipatterns.md, then return to this issue.")

### 5. Output the brief

Use this structure (markdown, for the human to read in chat):

```markdown
## Issue brief: #N — [title]

**What this is.** [2-3 sentence summary of problem + why now, from the body.]

**You're agreeing to ship.**

- [ ] [AC item from the issue]
- [ ] ...

**Non-goals / constraints.**

- [constraint from the issue]
- ...

**ADRs in play.**

- ADR-NNN: [decision_outcome line from frontmatter] → docs/decisions.md#adr-nnn
- ...

**Conventions that bind this work.**

- `required`: [rule headline] (why: [reason snippet])
- `recommended`: [rule headline] (why: [reason snippet])
- ...

**Antipatterns to avoid.**

- "Don't [lever from antipatterns.md]" — [date, short title]
- ...

**Network / protocol contracts.** (only if relevant)

- [relevant section summary]

**Activity since last session:** X days. [Banner if > 7 days.]

---

Next step: I'll drop to plan mode and propose the implementation plan against current reality. Eyeball the brief above first; if anything looks off (a convention I missed, an ADR I misapplied, a constraint I overlooked), tell me before I start planning.
```

### 6. Hand off to plan mode

After the brief is rendered, enter plan mode and draft the implementation plan. The brief is the foundation; the plan is what gets executed today.

### 7. After plan-mode approval — optional: post a build log

If the maintainer opts in (or this is a habit in the project), post the brief plus the approved plan as a single comment on the issue:

```bash
gh issue comment N --body-file - <<'EOF'
[brief content + plan steps]
EOF
```

The pattern: issue body stays thin (no procedural rot per the antipattern in `antipatterns.md`); the comment captures a per-execution snapshot — what was in play, what we planned, dated. Future-you opening the issue after a long absence sees the actual build log instead of having to reconstruct it. Jeff Geerling does this on his own homelab repos and it's a nice habit.

This step is off by default. Worth offering at end-of-plan-mode if you don't know whether the maintainer wants it for this project. Skip without ceremony if they don't.

## When NOT to run this

- Quick fixes or 5-minute tasks (the brief overhead exceeds the value)
- Purely administrative work (label rename, comment-only edits)
- The same issue you worked yesterday (the brief is still fresh in your head)

## Why this skill exists

A long absence (months) is the failure mode where the project's intended path gets forgotten. activeContext.md handles "where was I." conventions / antipatterns / ADRs encode "what was the rule." This skill brings the relevant subset of both into the maintainer's face at the start of work, so the rules don't get silently dropped between sessions separated by months.

## Self-check

Before producing the brief, verify:

- Did I read activeContext.md (or note that it's missing)?
- Did I read the issue via `gh`, not from memory?
- Did I surface every ADR cited in the body?
- Did I surface every `required` convention rule?
- Did I check the long-absence threshold?

If any of the above is no, redo before rendering the brief.
