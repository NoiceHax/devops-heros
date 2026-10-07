# Session 13: Kubernetes Storage, HPA & Probes

All commands were run on Minikube (Docker driver, 4 CPU / 5 GB). Raw terminal output for every
module is in [`../transcripts/s13/`](../transcripts/s13/).

| Module | Folder | Transcript |
|---|---|---|
| 01 emptyDir, hostPath | `01-volumes/` | `01-emptydir.txt`, `02-hostpath.txt` |
| 02 PV + PVC | `02-persistent-storage/` | `03-pv-pvc.txt` |
| 03 StorageClass, dynamic provisioning | `03-storageclass/` | `04-storageclass.txt` |
| 04 HPA | `04-hpa/` | `04-hpa.txt` (idle), `05-hpa-under-load.txt` |
| 05 Probes | `05-probes/` | `06-probes.txt` |
| Mini project | `06-mini-project/` | `07-mini-project.txt` |

## Task 1: Kubernetes volumes

| Type | Lifetime | What I observed |
|---|---|---|
| `emptyDir` | Same as the **Pod** | After killing nginx, the container restarted and `/data/note.txt` was still there. After deleting and recreating the Pod, `/data` was empty. |
| `hostPath` | Same as the **node** | The file survived Pod deletion and was visible on the node itself (`minikube ssh`). It ties data to one node, so it is for demos and node agents, not apps. |
| `PersistentVolume` | Independent of Pods | Admin-side storage object. `student-pv` is 1Gi with `Retain`. |
| `PersistentVolumeClaim` | Independent of Pods | A Pod's request for storage. `student-pvc` (500Mi) bound to `student-pv`; data written by one Pod was read by the next. |
| `StorageClass` | n/a | Describes *how* to create volumes. Minikube's default `standard` uses `k8s.io/minikube-hostpath`. |
| Dynamic provisioning | n/a | Creating `dynamic-pvc` with `storageClassName: standard` produced a new PV automatically, with no hand-written PV. |

Things worth remembering from the runs:

- **`Retain`**: deleting the PVC left the PV in `Released` state with its data. A `Delete` class (the default
  `standard`) removes the PV and its data along with the claim.
- **Typo in `storageClassName`** (`pvc-typo.yaml`, `fast-disk`): the PVC stays `Pending` forever.
  `kubectl describe pvc` shows `storageclass.storage.k8s.io "fast-disk" not found`.
- **`WaitForFirstConsumer`** (`sc-wait.yaml`): `wait-pvc` stays `Pending` *on purpose* until a Pod uses it, so
  the volume is created on the node where the Pod is scheduled. It turned `Bound` after `wait-demo` started.
- **Static vs dynamic claims**: `pvc-static.yaml` uses `storageClassName: ""` to opt out of the default class so it binds to
  the hand-written PV. Without that, the default class would provision a new volume and the PV would be ignored.

## Task 2: HPA hands-on

Manifests: `deployment.yaml` (nginx, CPU request 100m), `service.yaml`, `hpa.yaml` (min 1, max 5, target 50% CPU),
`load-generator.yaml` (busybox running `wget` loops).

Result from `05-hpa-under-load.txt`:

| Time | CPU (of request) | Replicas |
|---|---|---|
| Idle | 7% | 1 |
| ~t+80s, load running | 105% / 50% | 1 |
| ~t+100s | 105% / 50% | **3** (`SuccessfulRescale ... above target`) |
| ~t+140s | 79% / 50% (spread across 3 Pods) | 3 |

How it works: the HPA reads CPU from metrics-server every ~15s and computes
`desired = ceil(current replicas × current / target)`, so `ceil(1 × 105 / 50) = 3`. The load generator uses 2 loops
(the original used 4) because this laptop has only 4 cores. Once the load is gone, the HPA waits a 5-minute stabilization
window before scaling back down.

Note: the first `get hpa` shows `cpu: <unknown>/50%`. metrics-server needs about a minute after a Pod starts, and the
`FailedGetResourceMetric` warnings in the events are that same delay, not a fault.

Commands used: `kubectl get hpa`, `kubectl get pods`, `kubectl top pods`, `kubectl describe hpa`.

## Task 3: Probes

| Probe | Purpose | On failure | Demo |
|---|---|---|---|
| `startupProbe` | Gives slow apps time to boot; disables the other probes until it succeeds | Container restarted | `startup-demo.yaml` (30 × 2s = 60s allowance) |
| `readinessProbe` | Is the Pod ready for traffic? | Pod removed from Service endpoints, **not** restarted | Moved `index.html` away: `READY 0/1`, `RESTARTS 0`. Restored it: back to `1/1`. |
| `livenessProbe` | Is the container still healthy? | Container **restarted** | A probe on `/nope` returned 404 and `RESTARTS` climbed to 3 with `Killing ... will be restarted` events. |

## Task 4: Mini project (`06-mini-project/`)

Namespace `production-webapp` with a 500Mi PVC, a 2-replica nginx Deployment with all three probes, a ClusterIP Service,
and an HPA (2 to 5, 50% CPU). Verified in `07-mini-project.txt`:

- PVC `web-data` is `Bound` via the `standard` class.
- Wrote `/data/proof.txt`, deleted the Pod, and the replacement Pod still had the file.
- All three probes are present on the Pods.
