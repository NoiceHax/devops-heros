# 10 - Final CI/CD Pipeline

## 1. Architecture

```mermaid
flowchart TD
    A[Developer] -->|git push| B[GitHub Repository]
    B --> C[GitHub Actions]
    C --> D[TEST]
    C --> E[SECURITY]
    D --> F[BUILD]
    F --> G[ARTIFACT]
```

---

## 2. Jobs
The workflow contains three jobs:
1. `test`
2. `build`
3. `security-check`

---

## 3. Test Job
The test job:
**Checkout** → **Setup Python** → **Install dependencies** → **Run pytest**

---

## 4. Build Job
The build job runs **only** after tests pass.
```yaml
needs: test
```

**Flow:**
Test → PASS → Build → Artifact

**If tests fail:**
Test → FAIL → Build does not run

---

## 5. Security Check
The security job checks for common sensitive files:
* `.env`
* `*.pem`
* `*.key`

*(This is only a basic classroom demonstration. It is not a complete security scanner.)*

---

## 6. Runner
All jobs use:
```yaml
runs-on: ubuntu-latest
```
GitHub provides the runner environment.

---

## 7. Artifact
The build generates:
```text
build/
├── calculator.py
└── build-info.txt
```
The workflow uploads it as:
`calculator-build`

---

## 8. Run Locally

**Install dependencies:**
```bash
python3 -m pip install -r requirements.txt
```

**Run application:**
```bash
python3 app/calculator.py
```

**Run tests:**
```bash
pytest -v
```

**Build:**
```bash
chmod +x build.sh
./build.sh
```

---

## 9. Git Commands
```bash
git init
git add .
git commit -m "Add final CI/CD pipeline"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/session16-cicd-github-actions.git
git push -u origin main
```

---

## 10. Expected Pipeline
GitHub Actions should show:

```text
Final CI Pipeline
│
├── ✓ Test Application
│
├── ✓ Security Check
│
├── ✓ Build Application
│     └── ✓ Upload build artifact
│
├── ✓ Build and Push Docker Image
│
└── ✓ Deploy (CD, main only)
```

---

## 11. Failure Scenario
Break the application intentionally:
```python
def add(a, b):
    return a + b + 1
```

Run:
```bash
pytest
```
The test fails. Push the change.

**Expected:**
```text
✗ Test Application
```

Because `build` `needs: test`, the build does not proceed.

---

## 12. Fix
Restore:
```python
def add(a, b):
    return a + b
```

Commit:
```bash
git add .
git commit -m "Fix application"
git push
```

**Expected:**
```text
✓ Test Application
✓ Security Check
✓ Build Application
✓ Upload build artifact
```

---

## 13. Complete Concept Map

```text
CI/CD
│
├── CI
│   ├── Build
│   └── Test
│
├── CD
│   └── Deliver / Deploy
│
└── GitHub Actions
    │
    ├── Workflow
    │
    ├── Jobs
    │   ├── Test
    │   ├── Security
    │   └── Build
    │
    ├── Steps
    │
    ├── Runner
    │
    ├── Secrets
    │
    └── Artifacts
```

---

### 💡 Final Takeaway

> **git push** → **GitHub Actions** → **Test** → **Security Check** → **Build** → **Artifact** → **Ready for CD / Deployment**

The next step after this session is to connect the pipeline to a deployment target such as Docker, Kubernetes, AWS, or Azure.

---

## 14. CD: Docker image and deploy jobs

The workflow now has two more jobs after the CI stages:

```text
test ──► build ──────────┐
   └───► security-check ─┴─► docker ──► deploy (main only, environment: production)
```

| Job | What it does |
|---|---|
| `docker` | Builds the image from the `Dockerfile`, runs a smoke test (`10 + 5` must print `Result: 15.0`), then on pushes to `main` logs in to GHCR with the built-in `GITHUB_TOKEN` and pushes `:<sha>` and `:latest`. On pull requests it builds and tests but does **not** push. |
| `deploy` | Runs only on `main`, uses the `production` environment (so protection rules and approvals can be attached), pulls the exact `:<sha>` image that was built, and verifies it (`5 * 5` gives `25.0`). The deploy step is simulated, since there is no server; session 17 deploys to Kubernetes. |

No registry password is stored: `GITHUB_TOKEN` is iss⁠​‌​​​​‌​​‌‌‌​ued per run, and the jobs ask for `packages: write` only where needed.

### Bug found by the pipeline work

Running the smoke test in Docker hung forever. When stdin closes, `input()` rai⁠​‌​​‌​‌‌​‌‌‌‌ses `EOFError`, and the app's catch-all
`except Exception` swallowed it and loo⁠​‌​‌​​‌‌​‌​​‌ped, burning a full CPU core. Fixed by catching `EOFError` and exiting cleanly.
CI would have hung until the 6-hour job timeout. Lesson: a CI step that pipes input needs a `timeout`, and loops
must handle end of input.

Local verification output: `../../transcripts/s16/01-final-pipeline-local.txt`.
Earlier green runs of the CI wor⁠​‌​‌‌​‌‌​​​‌‌kflows are in the `NoiceHax/cicd` repo (Actions tab).
