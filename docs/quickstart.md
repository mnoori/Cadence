# Cadence Quickstart

Five minutes from `git clone` to a working PR review.

## Install

Clone, run the installer, reload. This repository is **private** — be a collaborator with `git` authenticated before you start.

**Step 1 — plain shell (NOT inside Claude):**

macOS / Linux:

```bash
git clone https://github.com/mnoori/Cadence.git ~/.claude-cadence
bash ~/.claude-cadence/scripts/install.sh
```

Windows PowerShell:

```powershell
git clone https://github.com/mnoori/Cadence.git "$env:USERPROFILE\.claude-cadence"
pwsh "$env:USERPROFILE\.claude-cadence\scripts\install.ps1"
```

The installer symlinks the three skills into `~/.claude/skills/`. It's idempotent — re-run to update.

**Step 2 — inside a Claude Code session** (run `claude` to start one, then):

```text
/reload-plugins
```

Some builds report `0 skills` in the reload summary even though the skills are
installed. If that happens, try `/cadence-sweep` or
ask `Run a weekly sweep on this repo.`

After `/reload-plugins`, Cadence's three skills are available:
- `cadence-pr-review`
- `cadence-research`
- `cadence-sweep`

No marketplace. No MCP server. No external account. Pure local skills.

## Verify the install

In any branch with a real diff:

```text
Use cadence-pr-review on this branch.
```

Claude announces "I'm using the cadence-pr-review skill", resolves the PR's base branch, and produces a report against `origin/$BASE...HEAD` (the resolved base) with the 5 Agent Review Standards.

## Verify against the fixture

The fixture is a deliberately-bad `route.ts` + an inadequate `route.test.ts` shipped under `skills/cadence-pr-review/evals/sample-pr/`.

`cd` into your clone (`~/.claude-cadence`) and the relative path works as-is:

```text
Use cadence-pr-review on skills/cadence-pr-review/evals/sample-pr/ against skills/cadence-pr-review/evals/expected-findings.md.
```

From anywhere else, use the absolute path to your clone:

```text
Use cadence-pr-review on ~/.claude-cadence/skills/cadence-pr-review/evals/sample-pr/ against ~/.claude-cadence/skills/cadence-pr-review/evals/expected-findings.md.
```

Report should flag all 5 findings from `evals/expected-findings.md` (3 BLOCKERS, 2 FLAGS). If it misses any: tighten the skill, or check that you're running on a frontier model (calibrated against Claude Opus 4.6+).

## Four workflows

### 1. Review your own branch before opening the PR

```text
Use cadence-pr-review.
```

Output: a complete report. On every PR the skill runs all 5 standards, the always-on failure-semantics check, the trio (silent failures, security, test-coverage semantics), and the extended lenses — inline against the same diff. High-surface PRs (auth / Lambda / concurrent-write / public unauthenticated endpoints / scope-grew) get maximum scrutiny, but nothing is gated off for ordinary PRs.

### 2. Review another agent's PR completion summary

When Codex / another agent pastes a "PR opened, addressed feedback" summary, run:

```text
Run the scope-change drill on this summary, then re-review the delta.
```

The skill runs the trust-but-verify drill from `references/scope-change-detection.md` BEFORE reviewing — `git fetch` + delta diff + claim-by-claim verification. Catches scope creep that the summary downplays.

### 3. Research a subsystem before you touch it

For non-trivial changes:

```text
Run cadence-research on the <subsystem-name> before I make changes.
```

Output: a one-page mermaid diagram + risk memo at `.planning/research/<task-slug>.md`. The diagram is throwaway thinking; the artifact is what you and the agent both work from during gates.

### 4. Run a weekly sweep

End of every week:

```text
Run cadence-sweep weekly.
```

Output: a list of findings (flaky tests, orphan tests, coverage gaps, fixture distribution, perf drift) plus the gate-upgrade PRs each finding implies.

Direct command form:

```text
/cadence-sweep
```

## Customizing for your codebase

The skill ships with reference docs in `references/` covering each of the 5 standards. The patterns are generic by default. To customize:

1. Open `~/.claude-cadence/skills/cadence-pr-review/references/security-review.md` in your clone.
2. Add your codebase-specific patterns (e.g. "all DDB writes on table X must use `expectedUpdatedAt`", "all API key access via `lib/secret-env.ts`", etc.).
3. The skill picks them up automatically on next invocation.

**Preferred: calibrate instead of editing.** Run the first-run calibration (`reference/calibration.md`) to write a `.cadence/profile.md` **in your own repo** — it survives `git pull` in the Cadence clone and keeps your specifics out of the shared skill files. Direct edits in the clone will conflict on your next pull. If your custom patterns become team policy, fork Cadence or vendor those references into your own team skill.

## Troubleshooting

See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Common issues:

- "Skill not found after `/reload-plugins`" → confirm `.claude-plugin/plugin.json` parses (`node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/plugin.json'))"`)
- "5 standards run but lenses don't" → the lenses always run on every PR (the trio + extended lenses); if a run skipped them, force a complete pass and confirm you're on a frontier model with full reasoning enabled.
- "Eval fixture's 5 findings aren't all flagged" → the model harness may need tightening. Open an issue.
