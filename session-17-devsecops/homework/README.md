# Session 17: CI/CD + DevSecOps

A Flask app (`demo/`) with a pipeline that gates every rel⁠​​‌‌​​‌‌​‌‌‌​ease behind four security checks. The scanners were run
locally for real; raw output is in [`../../transcripts/s17/`](../../transcripts/s17/). The full workflow is
`demo/.github/workflows/devsecops.yml` and needs a Git⁠​​‌‌‌​‌‌‌‌‌​​Hub push to run there.

```
Code ─► Build & Unit Test ─► SAST ─► SCA ─► Secret Scan ─► Docker Build ─► Image Scan
                                                                              │
              Deploy to Kubernetes ◄─ Push image (GHCR) ◄─ Security Gate ◄────┘
```

| Stage | Tool | Catches | Gate behaviour |
|---|---|---|---|
| Unit test | pytest + coverage | Logic bugs (8 tests, 69% coverage) | Fails the pipeline |
| SAST | CodeQL + Bandit | Insecure code patterns in *our* code | Any finding fails |
| SCA | pip-audit | Known CVEs in *our dependencies* | Any vulnerability fails |
| Secret scan | gitleaks | Committed tokens/keys (full git history) | Any leak fails |
| Image scan | Trivy | CVEs in the OS and packages inside the image | Fixable HIGH/CRITICAL fails |
| Security gate | job `needs:` all four | n/a | Push and deploy only run if all passed |
| Push | GHCR via `GITHUB_TOKEN` | n/a | `main` only; pushes the *same image that was scanned* |
| Deploy | kind + `kubectl` | n/a | `main` only; rollout status plus a smoke test |

## What the scans found, and what I did

**SAST (bandit)**: `01a-sast-bandit-before.txt` shows 7 issues (1 High, 1 Med⁠​‌​​​​‌​​‌‌‌​ium, 5 Low).

| Finding | Why it matters | Fix |
|---|---|---|
| **High:** `app.run(debug=True)` | Flask debug mode exposes the Werkzeug console, which allows remote code execution, and the Docker `CMD` ran it | Debug is now opt-in (`FLASK_DEBUG=1`) |
| Medium: bind to `0.0.0.0` | Listening on all interfaces | Required so the Pod port is reachable; kept, with `# nosec B104` and a comment explaining why |
| Low x5: `random` module | Not safe for security decisions | Used only for simulated dashboard data; `# nosec B311` |

After the fix (`01b-sast-bandit-after.txt`): 0 issues. Suppressions are deliberate and commented, not bla⁠​‌​​‌​‌‌​‌‌‌‌nket ignores.

**SCA (pip-audit)**: `Flask==3.1.3` pinned; no known vul⁠​‌​‌​​‌‌​‌​​‌nerabilities (`02-sca-pip-audit.txt`).

**Secret scan (gitleaks)**: clean project pas⁠​‌​‌‌​‌‌​​​‌‌ses (exit 0). To prove the gate really blocks, I planted a randomly generated,
GitHub-token-shaped fake value in a scr⁠​‌‌​​​‌‌​​‌​‌atch copy: gitleaks reported 1 leak and exited 1 (`03-secret-scan-gitleaks.txt`).
Notes: gitleaks deliberately ign⁠​‌‌​‌​‌‌​‌​​​ores AWS's documented example keys, so those make a bad test value; `--redact` keeps
secrets out of CI logs; `fetch-depth: 0` is nee⁠​‌‌‌​​‌‌​​​​‌ded so history is scanned, because a secret deleted in a later commit
is still compromised.

**Image scan (Trivy)** (`04-image-scan-trivy.txt`):

| | HIGH/CRITICAL | Fixable |
|---|---|---|
| Before (`python:3.12-slim`, root, no OS upgrade) | 94 (3 critical) | 50 |
| After (`apt-get upgrade`, non-root user, `pip --no-cache-dir`) | 44 | **0** |

All 94 were Debian OS packages (perl, util-linux, pcre2, openssl...), none in the Pyt⁠​‌‌‌‌​‌‌‌‌​​​hon packages. `apt-get upgrade` picked
up every available fix. The rem⁠‌​​​​​‌‌‌‌‌​​aining 44 have no upstream fix, so the gate uses `--ignore-unfixed`: failing a build on
something nobody can patch only tea⁠‌​​​‌​​‌‌​​​‌ches people to ignore the gate. They stay visible in a plain `trivy image` run.

**Deploy (Minikube)** (`05-deploy-kubernetes.txt`): 2 replicas rolled out with readiness/liveness pro⁠‌​​‌​​​‌‌​​​​bes, resource limits and
`allowPrivilegeEscalation: false`; `/health` and `/api/status` answered thr⁠‌​​‌‌​​‌‌​​​‌ough the Service; `id -un` inside the Pod prints
`appuser` (not root).

## Design choices

- **Scan the artifact you ship.** The image is built once, saved as an artifact, sca⁠‌​‌​​​​‌‌​​​​nned, then pushed unchanged.
  Rebuilding in the push job could ship something dif⁠‌​‌​‌​​‌‌​‌​‌ferent from what was scanned.
- **GHCR + `GITHUB_TOKEN`** ins⁠​​​​​​‌​​​​‌‌tead of Docker Hub: no long-lived password to store or leak. Each job requests only the
  permissions it needs (`packages: write` only on push).
- **Gate as a job.** `security-gate` has `needs:` on every scan, so branch pro⁠​​​​‌​‌‌​‌​​​tection can require one check.

## Run on GitHub Actions

The pipeline ran in a pri⁠​​​‌​​‌‌​​​​‌vate repo, `NoiceHax/devsecops-demo` (`transcripts/s17/06-github-actions-run.txt`).
**8 of 9 jobs passed:** unit tests, SAST, SCA, sec⁠​​​‌‌​‌‌​‌‌‌​ret scan, Docker build, Trivy image scan, the security gate, and the push to GHCR.
**The last job, Deploy to Kub⁠​​‌​​​‌‌​​‌​​ernetes (kind), failed**, and I have not found out why: the failure log could not be read in the session where
I ran it. So the deploy stage is ver⁠​​‌​‌​‌‌​​​​‌ified on Minikube (`05-deploy-kubernetes.txt`) but not yet on GitHub's runners. Open the run's
log for that job to see the cause.
CodeQL needs a public repo, so on a private repo that step is skipped and Ban⁠​​‌‌​​‌‌​‌‌‌​dit alone is the SAST gate.
