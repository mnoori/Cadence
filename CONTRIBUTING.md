# Contributing to Cadence

Thanks for considering a contribution.

## What we accept

- **New patterns for any of the 5 standards** — security checks, drift detection, architectural conventions, test-coverage gaps. Add to the relevant `skills/cadence-pr-review/references/<standard>.md`.
- **New eval fixtures** — synthetic-but-plausible diffs that exercise specific standards. Add to `skills/cadence-pr-review/evals/` with an accompanying `expected-findings.md`.
- **New sweep targets** — recurring drift classes the cadence table doesn't yet cover. Add to `skills/cadence-sweep/references/cadence-table.md`.
- **Worked examples** — anonymized real-world PR-review stories. Add to `docs/examples/`.
- **Bug fixes** for skills that misbehave on real diffs.

## What we don't accept

- **Codebase-specific patterns.** Cadence is generic. If a finding only matters to one team's codebase, it belongs in that team's `.cadence/profile.md` or a vendored fork — not here.
- **Vendor-specific patterns** unless broadly applicable. AWS Cognito gotchas are fine; a single-vendor SDK quirk usually isn't.
- **MCP server additions.** Cadence is intentionally local-only. No external dependencies.

## Workflow

1. Open an issue describing the gap or pattern.
2. Fork, branch, commit (frequent commits, conventional-commit messages).
3. Run `pnpm lint` (or `npm run lint`) — markdownlint must pass.
4. Open a PR.
5. Self-review against `cadence-pr-review` (eat your own dogfood).

## Eval discipline

Every new pattern in a standard's reference doc (or a new lens) should come with a fixture in its own `evals/<scenario>/` directory and a matching `expected-findings-<scenario>.md` answer key, wired into `evals/RUN-EVAL.md`. Patterns without evals are not enforceable. When you add a fixture, run it blind against a frontier model and confirm the answer key is matched before opening the PR — and add a clean/PASS counterpart if the pattern risks false positives.

## Style

- Markdown headers: ATX (`#`), not Setext.
- Code blocks: fenced with language hint.
- Keep verbatim quotes from external talks short and italicized with attribution; otherwise paraphrase in your own words.
- No emojis in skill files; emojis in user-facing docs are fine but sparing.

## Conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). Contributor Covenant 2.1.
