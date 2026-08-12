# Troubleshooting

## Install issues

### "`git clone` fails with authentication / not-found"

This repository is **private**. A 404 on clone usually means auth, not a typo —
GitHub returns "not found" rather than "forbidden" for private repos you can't
read. Confirm you've been added as a collaborator, then authenticate:

```bash
gh auth login
```

Or use an SSH remote if you have a key registered:

```bash
git clone git@github.com:mnoori/Cadence.git ~/.claude-cadence
```

### "Where does the installer put things?"

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

The installer links `cadence-pr-review`, `cadence-research`, and
`cadence-sweep` into your Claude skills directory (`~/.claude/skills/`). It skips
any existing non-symlink skill directory instead of overwriting it. Override the
defaults with `CADENCE_DIR`, `SKILLS_DIR`, `REPO_URL`, or `BRANCH` env vars.

### "Skill not found after `/reload-plugins`"

Verify the manifest parses:

```bash
node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/plugin.json'))"
```

Should print nothing and exit 0. If it errors, fix the JSON syntax.

Then confirm the symlinks actually landed:

```bash
ls -la ~/.claude/skills/ | grep cadence
```

You should see three entries pointing into your clone. If they're missing, re-run
the installer — it's idempotent.

### "`/reload-plugins` says 0 skills"

Some builds report `0 skills` in the reload summary even when the skills are
available. Test a command directly:

```text
/cadence-sweep
```

If that command runs, Cadence is installed. You can also invoke it in natural
language: `Run a weekly sweep on this repo.`

### "Skills directory shows but skills don't appear"

Each skill needs a `SKILL.md` directly under `skills/<skill-name>/`. Run:

```bash
ls skills/*/SKILL.md
```

Should list 3 files (`cadence-pr-review`, `cadence-research`, `cadence-sweep`). Missing one means the corresponding skill won't load.

## Runtime issues

### "The 5 standards ran but the lenses didn't"

That's a bug in the run — **the lenses always run on every PR.** The trio (silent failures / security / test semantics) and the extended lenses (migration / idempotency / dependency / rollout) run after the 5 standards on every review; on a diff with no relevant surface they report `N/A` in one line rather than being skipped. The trigger lists in `specialist-trio.md` only mark where the lenses bite hardest, not whether they run.

If a run skipped them, force a complete pass: `Use cadence-pr-review and run the full trio and all extended lenses — no skipping.` Also confirm you're on a frontier model with full reasoning/thinking enabled.

### "Eval fixture findings aren't all flagged"

The plugin ships **five** eval fixtures, each with its own answer key (see `evals/RUN-EVAL.md`):
`sample-pr/` (5 standards + failure-semantics), `lambda-pr/` and `auth-pr/` and `rate-limit-pr/` (the trio lenses), and `clean-pr/` (must produce `VERDICT: PASS` — false-positive calibration). If your install misses findings or invents them on `clean-pr/`:

1. Run review on a frontier model (Claude Opus 4.6 or newer) with maximum reasoning/thinking enabled — review is not where to economize. The trio fixtures (`lambda-pr`/`auth-pr`/`rate-limit-pr`) are the most demanding; if they miss findings, raise the model/thinking budget first.
2. Check the prompt — `Use cadence-pr-review on <branch-or-fixture>` should be sufficient.
3. Open an issue with the report you got and the model used.

### "Skill recommends scope-change drill but I'm just reviewing my own branch"

The drill is mandatory when an agent's completion summary is in the conversation history. If you're reviewing your own work, the drill is a no-op safety check (it'll find that scope didn't grow and fall through to the standards). Not a bug.

## Customization issues

### "I added a pattern to references/security-review.md but it's not firing"

Confirm the file is at the right path. References live in your clone under
`~/.claude-cadence/skills/cadence-pr-review/references/` (on Windows,
`%USERPROFILE%\.claude-cadence\skills\cadence-pr-review\references\`). Edit
there, then `/reload-plugins`.

Because the installer symlinks rather than copies, edits in the clone take
effect in place — but they will conflict on your next `git pull`. The durable
path is the first-run calibration (`reference/calibration.md`), which writes a
`.cadence/profile.md` into **your** repo instead. If the pattern is team policy,
fork Cadence or vendor the reference file into your own team skill.

## Reporting bugs

Open an issue at https://github.com/mnoori/Cadence/issues. Include:

- Cadence version (`cat .claude-plugin/plugin.json | grep version`)
- Claude Code version
- Model in use
- The diff or PR description that triggered the bug
- Expected vs actual report
