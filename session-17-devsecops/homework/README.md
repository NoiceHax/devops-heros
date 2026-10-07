# Session 17: CI/CD + DevSecOps

A Flask app (`demo/`) with a pipeline that gates every release behind four security checks. The scanners were run
locally for real; raw output is in [`../../transcripts/s17/`](../../transcripts/s17/). The full workflow is
`demo/.github/workflows/devsecops.yml` and needs a GitHub push to run there.

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

**SAST (bandit)**: `01a-sast-bandit-before.txt` shows 7 issues (1 High, 1 Medium, 5 Low).

| Finding | Why it matters | Fix |
|---|---|---|
| **High:** `app.run(debug=True)` | Flask debug mode exposes the Werkzeug console, which allows remote code execution, and the Docker `CMD` ran it | Debug is now opt-in (`FLASK_DEBUG=1`) |
| Medium: bind to `0.0.0.0` | Listening on all interfaces | Required so the Pod port is reachable; kept, with `# nosec B104` and a comment explaining why |
| Low x5: `random` module | Not safe for security decisions | Used only for simulated dashboard data; `# nosec B311` |

After the fix (`01b-sast-bandit-after.txt`): 0 issues. Suppressions are deliberate and commented, not blanket ignores.

**SCA (pip-audit)**: `Flask==3.1.3` pinned; no known vulnerabilities (`02-sca-pip-audit.txt`).

**Secret scan (gitleaks)**: clean project passes (exit 0). To prove the gate really blocks, I planted a randomly generated,
GitHub-token-shaped fake value in a scratch copy: gitleaks reported 1 leak and exited 1 (`03-secret-scan-gitleaks.txt`).
Notes: gitleaks deliberately ignores AWS's documented example keys, so those make a bad test value; `--redact` keeps
secrets out of CI logs; `fetch-depth: 0` is needed so history is scanned, because a secret deleted in a later commit
is still compromised.

**Image scan (Trivy)** (`04-image-scan-trivy.txt`):

| | HIGH/CRITICAL | Fixable |
|---|---|---|
| Before (`python:3.12-slim`, root, no OS upgrade) | 94 (3 critical) | 50 |
| After (`apt-get upgrade`, non-root user, `pip --no-cache-dir`) | 44 | **0** |

All 94 were Debian OS packages (perl, util-linux, pcre2, openssl...), none in the Python packages. `apt-get upgrade` picked
up every available fix. The remaining 44 have no upstream fix, so the gate uses `--ignore-unfixed`: failing a build on
something nobody can patch only teaches people to ignore the gate. They stay visible in a plain `trivy image` run.

**Deploy (Minikube)** (`05-deploy-kubernetes.txt`): 2 replicas rolled out with readiness/liveness probes, resource limits and
`allowPrivilegeEscalation: false`; `/health` and `/api/status` answered through the Service; `id -un` inside the Pod prints
`appuser` (not root).

## Design choices

- **Scan the artifact you ship.** The image is built once, saved as an artifact, scanned, then pushed unchanged.
  Rebuilding in the push job could ship something different from what was scanned.
- **GHCR + `GITHUB_TOKEN`** instead of Docker Hub: no long-lived password to store or leak. Each job requests only the
  permissions it needs (`packages: write` only on push).
- **Gate as a job.** `security-gate` has `needs:` on every scan, so branch protection can require one check.
- **Not run on GitHub yet.** CodeQL needs code scanning enabled on the repo, and the push/deploy jobs only run on `main`.
