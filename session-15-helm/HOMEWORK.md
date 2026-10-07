# Session 15: Helm

Helm v4.3.0 on Minikube. Raw output: [`../transcripts/s15/`](../transcripts/s15/).

```
session-15-helm/
└── mini-project/notes-chart/      # Chart.yaml, values.yaml, values-prod.yaml, templates/{deployment,service,configmap}.yaml
```

## Task 1: Helm commands (`01-helm-commands.txt`)

| Command | What it does | Seen in the run |
|---|---|---|
| `helm repo add / update / list` | Register a chart repository and refresh its index | Added `bitnami`; `repo list` shows it |
| `helm search repo` / `search hub` | Find charts in added repos / on Artifact Hub | `bitnami/nginx` and friends |
| `helm create demo-chart` | Scaffold a chart (`Chart.yaml`, `values.yaml`, `templates/`) | Generated the standard layout |
| `helm lint` | Static checks on a chart | `0 chart(s) failed` |
| `helm template` | Render templates locally without installing | Used in the mini project |
| `helm install demo demo-chart` | Create a **release** (revision 1) | `STATUS: deployed`, `REVISION: 1` |
| `helm list` | Releases in the namespace | `demo` deployed |
| `helm status` | Release state, notes | |
| `helm get values / manifest` | What was supplied / what was rendered and sent to the cluster | `--all` includes chart defaults |
| `helm upgrade` | New revision with changed values or chart | `--set replicaCount=2` gave revision 2 |
| `helm history` | One row per revision | `1 superseded`, `2 deployed` |
| `helm rollback demo 1` | Re-deploy an old revision **as a new revision** | History shows revision 3, "Rollback to 1" |
| `helm uninstall` | Remove the release and its resources | `helm list` is empty |

Key idea: a *chart* is the package, a *release* is one installed instance of it, and every change creates a new
numbered *revision* that can be rolled back to.

## Task 2: Rollback workflow (`02-rollback-workflow.txt`)

| Step | Action | Result |
|---|---|---|
| Install | `helm install notes` (dev values) | rev 1: 1 replica, `nginx:1.24` |
| Verify | `kubectl get deploy` | 1 replica, `nginx:1.24` |
| Upgrade | `-f values-prod.yaml` | rev 2: 3 replicas, `nginx:1.25` |
| Verify | rollout finished | 3 replicas, `nginx:1.25` |
| Upgrade again | `--set image.tag=does-not-exist` (bad release) | rev 3: new Pod `ImagePullBackOff`; the 3 old Pods kept serving because the rolling update never removed them |
| Rollback | `helm rollback notes 2` | rev 4 "Rollback to 2" |
| Verify | `kubectl get pods`, `get deploy` | 3 healthy Pods, `nginx:1.25`, the broken Pod is gone |

Note that `helm history` shows rev 4 (a *new* revision whose content equals rev 2), not a rewind to rev 2. Helm
never deletes revision history on rollback.

## Task 3: Mini project, notes-chart (`03-mini-project.txt`)

A chart for a Notes app (nginx) with a Deployment, a NodePort Service and a ConfigMap, all driven by values.

- `values.yaml` is development (1 replica, `nginx:1.24`); `values-prod.yaml` is production (3 replicas, `nginx:1.25`).
- `{{ .Release.Name }}` prefixes every resource name, so the same chart can be installed multiple times.
- The Deployment carries a `checksum/config` annotation computed from the ConfigMap, so changing the ConfigMap
  rolls the Pods. Without it, Pods would keep the old env vars after an upgrade.
- `helm lint` passed, `helm template` rendered cleanly, and `curl http://<minikube-ip>:30090` returned the nginx page.
- Upgrading the same release with `-f values-prod.yaml` moved it to 3 replicas and changed `ENVIRONMENT` in the
  ConfigMap to `production`.
