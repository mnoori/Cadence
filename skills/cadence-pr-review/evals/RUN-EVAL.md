# Running the evals

The eval suite has five fixtures. The first calibrates the 5 standards + the
always-on Failure-Semantics check; the next three calibrate the trio lenses
(the novel, high-value capability that the standards alone miss); the last
calibrates AGAINST false positives.

1. Open Claude Code in the Cadence repo (or point at the install path).
2. For each fixture below, ask the model to run `cadence-pr-review` on the
   fixture directory against its expected-findings file.
3. Compare the produced report against the expected file. Every BLOCKER/FLAG
   listed must appear at the same severity. If any is missed (or, for
   `clean-pr/`, invented), the skill or the harness needs tightening.

| Fixture | Exercises | Expected file | Must produce |
|---|---|---|---|
| `sample-pr/` | 5 standards + Failure Semantics (concurrency, observability, item-size, regression test) | `expected-findings.md` | 3 BLOCKERS, 2 FLAGS |
| `lambda-pr/` | Lens 1 on Python serverless (`URLError` bypass, secret-fallback predicate) | `expected-findings-lambda.md` | 2 BLOCKERS (+1 NOTE) |
| `auth-pr/` | Lens 2 on an auth module (JWT `aud`, `email_verified`, `token_use`, single-secret) | `expected-findings-auth.md` | 4 BLOCKERS, 1 FLAG |
| `rate-limit-pr/` | Trio cross-lens on a public endpoint (body-DoS, UA bypass, fail-closed, untested sniff) | `expected-findings-rate-limit.md` | 4 BLOCKERS |
| `clean-pr/` | False-positive calibration | `expected-findings-clean.md` | **VERDICT: PASS — 0 blockers, 0 flags** |

Example invocation (from inside the repo):

> Use cadence-pr-review on `skills/cadence-pr-review/evals/auth-pr/` against `skills/cadence-pr-review/evals/expected-findings-auth.md`.

From outside the repo, prefix the paths above with your clone location (default `~/.claude-cadence/`).

Always run review on a frontier model (Claude Opus 4.6+) with maximum reasoning/thinking enabled — review is not where to economize on model or budget. The trio fixtures (`lambda-pr`/`auth-pr`/`rate-limit-pr`) are the most demanding; if they miss findings while `sample-pr` passes, you're under-powered — raise the model/thinking before suspecting the skill.
