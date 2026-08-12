# Cadence

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-D97757)](https://docs.claude.com/en/docs/claude-code/plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-0068FF)](./LICENSE)
[![Version](https://img.shields.io/badge/version-0.3.0-00E6E2)](./CHANGELOG.md)

**Quality at agentic velocity. Research, Gates, Sweeps.**

When agents produce code 10–50× faster than your CI absorbs it, quality stops being a single review moment and becomes a recurring practice. Cadence ships the practice as installable Claude Code skills.

## Install

Clone the repo, run the installer. Cadence has no marketplace, no MCP server, and no external account — it installs pure local skills.

> This repository is **private**. You need to be a collaborator and have `git` authenticated (via `gh auth login` or an SSH key / PAT) before the clone will succeed.

### macOS / Linux

```bash
git clone https://github.com/mnoori/Cadence.git ~/.claude-cadence
bash ~/.claude-cadence/scripts/install.sh
```

### Windows PowerShell

```powershell
git clone https://github.com/mnoori/Cadence.git "$env:USERPROFILE\.claude-cadence"
pwsh "$env:USERPROFILE\.claude-cadence\scripts\install.ps1"
```

The installer symlinks `cadence-pr-review`, `cadence-research`, and `cadence-sweep` into your Claude skills directory (`~/.claude/skills/`). It's idempotent — re-run it any time to update, and it skips any existing non-symlink skill directory rather than overwriting it.

### Activate

Start a Claude Code session (`claude`), then:

```text
/reload-plugins
```

Some builds report `0 skills` in the reload summary even though the skills are
installed. The reliable check is to run one of the Cadence commands, such as
`/cadence-sweep`, or ask Claude in natural language:
`Run a weekly sweep on this repo.`

### Updating

```bash
git -C ~/.claude-cadence pull
```

Then `/reload-plugins` in your session.

### Try it — first runs after install

Inside the same Claude Code session, ask:

```text
Run a weekly sweep on this repo.
```

That triggers `cadence-sweep` to walk through the weekly drift checks and print findings + the gate-upgrade PRs each finding implies. Two more concrete first runs:

If you prefer the explicit command form:

```text
/cadence-sweep
```

```text
Use cadence-pr-review on the current branch.
```

```text
Run cadence-research on <subsystem-or-file> before I touch it.
```

---

## What you get — three skills on three different rhythms

Each skill maps to one of the three pillars. They fire on different cadences for a reason — see [Methodology](./docs/methodology.md).

| Skill | Pillar | When it fires | What it does |
|---|---|---|---|
| **`cadence-research`** | Research | Per-task, BEFORE work | Four-move research practice with an **executable command set** (map / inspect history / find seams + **blast radius** / produce artifact), a `RESEARCH.md` template, an acceptance checklist, a lite mode, and an explicit handoff to the gate, plus diagram-as-research thinking. Use before non-trivial changes — auth surfaces, concurrent-write paths, multi-agent config. |
| **`cadence-pr-review`** | Gates | Event-driven, AT change boundaries | Five Agent Review Standards (Codebase Drift, Conflicting PR, Security, Architectural Alignment, Test Coverage) + an **always-on Failure-Semantics & Observability check** + three trio lenses (silent failures, security, test-coverage semantics) + **extended lenses 4–7** (migration/backcompat, idempotency, dependency, rollout) + a scope-change drill. **Every pass runs on every PR** — triggers only mark where to look hardest, never whether to run. Dynamic base-branch resolution; five eval fixtures incl. a clean/PASS calibration set. Use before opening any PR. |
| **`cadence-sweep`** | Sweeps | Recurring (daily / weekly / monthly / quarterly) | Drift cleanup the gates can't catch (flaky tests, dependency lag, repeated review patterns) — now with an **executable query per sweep**, the **ratchet engine** (promote a recurring review FLAG to a hard gate rule), a **ratchet ledger** with a recurrence rule, and incremental scoping. Every sweep ships TWO things: cleanup PR AND a gate-upgrade PR. |

## The methodology

Three pillars on three rhythms. See [`docs/methodology.md`](./docs/methodology.md) for the full framing.

<details>
<summary><strong>The three pillars (click to expand)</strong></summary>

```text
                       ┌─────────────────────────────┐
                       │  SWEEPS  (recurring rhythm) │
                       │  "What is accumulating?"    │
                       │  → flaky tests, drift, gaps │
                       │    the gates missed         │
                       └─────────────┬───────────────┘
                                     │ output: stronger gates
                                     ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  GATES  (event-driven, at change boundaries)                   │
   │  "Can this work move forward?"                                 │
   │   L1 Fast Feedback     <10 min   25+ parallel checks           │
   │   L2 Behavioral         <15 min   E2E in real containers       │
   │   L3 Platform          per push   cross-platform               │
   │   L4 Human Ownership   pre-merge  CODEOWNERS + 5 review skills │
   │   L5 On-Demand          manual    real GPU / costly scenarios  │
   └────────────────────────────────┬───────────────────────────────┘
                                    │ guards
                                    ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  RESEARCH  (per-task, before work)                             │
   │  "What do we need to understand?"                              │
   │  Map the system → Inspect the history → Find the seams →       │
   │  Produce an artifact (plan, diagram, risk memo).               │
   │  "If the agent starts with the wrong mental model,             │
   │   speed just compounds the wrong answer."                      │
   └────────────────────────────────────────────────────────────────┘
```

</details>

> _Research reduces unknowns. Gates enforce what we know. Sweeps discover what we missed._

## The receipts

In the field test that produced this plugin, a real high-surface PR scored **0 BLOCKERS** under the 5 standards alone. Three specialist review angles — silent-failure semantics, security semantics, and test-coverage semantics — surfaced **4 BLOCKERS and 16 FLAGS** that would have shipped to production, including a rate-limit fail-closed-as-throttle conflation, a Python `urllib.error.URLError` bypass in a Lambda handler, a secret-fallback gate predicate, and a public endpoint whose magic-byte sniff was untested at the unit level. Cadence packages those three angles as inline review lenses you run as part of the same skill.

The 5 standards check **patterns**. The lenses check **semantics**. Both are necessary for high-surface code.

See [`docs/examples/reviewing-an-agent-pr.md`](./docs/examples/reviewing-an-agent-pr.md) for the full worked example.

## Quickstart

See [`docs/quickstart.md`](./docs/quickstart.md). Five minutes from `git clone` to a verified report.

## Why Cadence

Three things this plugin does that a generic "code review" tool doesn't:

1. **Layered gates with explicit time budgets.** The 5 standards are Layer 4 of a 5-layer gate ladder (L1 Fast Feedback <10 min, L2 Behavioral Verification <15 min, L3 Platform Coverage, L4 Human Ownership / 5 standards, L5 On-Demand Deep Checks). Velocity is preserved by the budgets.
2. **Specialist composition for semantics.** The 5 standards are pattern-checks. They miss semantics. Three additional review lenses (silent failures, security semantics, test-coverage semantics) catch the failure modes the standards can't see.
3. **Sweep-to-gate ratchet.** Every sweep ships TWO things: cleanup PR AND gate-upgrade PR. The bar gets stricter every cycle. That's the ratchet — without it, sweeps are just one-off cleanup.

## Customizing for your codebase

The skills ship with **generic patterns** that apply to most codebases. To layer your codebase-specific patterns:

1. Edit `~/.claude-cadence/skills/cadence-pr-review/references/<standard>.md` in your clone (the installer symlinks to it, so edits take effect in place).
2. Add your patterns to the relevant standard's checklist.
3. Run `/reload-plugins` (or restart the session). The skill picks up the changes on next invocation.

**Faster path — calibrate once.** Instead of editing the reference docs, run the first-run calibration (`reference/calibration.md`). It auto-detects your base branch, package manager, test runner, service/store/hook dirs, secret module, suite map, drift log, hot tables, and high-surface paths into a `.cadence/profile.md` **in your repo** (survives reinstalls and `git pull`). All three skills read it on every invocation. This is the preferred path — it keeps your specifics out of the Cadence clone entirely.

Edits made directly in the clone will conflict on your next `git pull`. If your patterns become team policy, fork Cadence or vendor the reference files into your own team skill.

This is the migration path: install with the generic patterns, layer your specifics on top.

## Attribution

The Research / Gates / Sweeps framing, the five Agent Review Standards, the layered PR gate budgets, and diagram-as-research were anchored by talks at **AI Agents 2026**, with reinforcing material across the conference (observability-as-verification, quality gates between research and production, the data/semantic/agent/trust layered stack). Cadence's contribution on top: the three inline review lenses, the scope-change drill, the sweep-to-gate ratchet, and the executable form. See [`reference/attribution.md`](./reference/attribution.md) for the full citation.

## License

[MIT](./LICENSE). Use freely.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Issues + PRs welcome. Add new patterns to the standards' reference docs as you discover them.

## Made by

Built for **Days of Build**. Cadence is the quality framework extracted from running AI agents against a real production codebase — generic by design, so it drops into any repo.
