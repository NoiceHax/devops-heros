# Session 14: Kubernetes Troubleshooting Report

Everything here was run on Minikube; raw output is in [`../transcripts/s14/`](../transcripts/s14/).
Each issue fol⁠​​​​​​‌​​​​‌‌lows the same loop: **identify, investigate, root cause, fix, verify**.

## Task 1: Command tour (`01-command-tour.txt`)

| Command | What it answers | Example from the run |
|---|---|---|
| `kubectl get pods [-o wide]` | What exists, and what state is it in? `-o wide` adds Pod IP and node. | `get-demo` Running on `minikube`, IP 10.244.x.x |
| `kubectl describe pod` | Why is it in that state? Events at the bottom are the best clue. | `Scheduled`, `Pulled`, `Created`, `Started` |
| `kubectl logs [--previous]` | What did the app print? `--previous` reads the last crashed container. | `logs-demo` printed "Application is healthy" |
| `kubectl exec` | Look from *inside* the container: files, DNS, connectivity. | `nginx -v`, `cat /etc/resolv.conf` |
| `kubectl events` | Cluster timeline for one object. | `events --for pod/get-demo` |
| `kubectl explain` | Built-in API docs for any field. | `explain deployment.spec.strategy` |
| `kubectl top` | Live CPU/memory (needs metrics-server). | `top pods`, `top nodes` |

## Task 2: Issues

| # | Symptom (`STATUS`) | Investigate | Root cause | Fix | Transcript |
|---|---|---|---|---|---|
| 1 | `Error` then `CrashLoopBackOff`, restarts climbing | `logs`, `describe` (Exit Code 1) | Process prints an error and runs `exit 1` | Run a process that stays alive (`fixed-pod.yaml`) | `02-crashloopbackoff` |
| 2 | `ErrImagePull` then `ImagePullBackOff` | `describe` events: "manifest unknown / not found" | Image tag does not exist | Use a real tag (`nginx:1.27`) | `03-imagepullbackoff` |
| 3 | `Pending`, no node | `describe` events: `FailedScheduling ... 0/1 nodes ... didn't match node selector` | `nodeSelector` names a node that doesn't exist | Remove or correct the selector | `04-pending` |
| 4 | `ContainerCreating` for a long time | `describe` events: `FailedMount ... configmap "app-settings" not found` | Pod mounts a ConfigMap that was never created | Create the ConfigMap; the kubelet retried and the Pod started | `05-containercreating` |
| 5 | `CreateContainerConfigError` | `describe`: `couldn't find key log_level in ConfigMap` | Env var asks for key `log_level`; ConfigMap key is `log-level` | Fix the key name | `06-configuration` |
| 6 | Service resolves but `Connection refused` | `describe svc`: `TargetPort 8080`; `wget` to the Pod IP on `:80` works | Service `targetPort` 8080, nginx listens on 80 | Set `targetPort: 80` | `07-service-dns-networking` |
| 7 | Pod networking | Compared Service path vs direct Pod IP path (see #6) | Pod network is fine; the fault was in the Service mapping | n/a | `07-service-dns-networking` |
| 8 | DNS | `nslookup web-svc` and FQDN worked; `nslookup does-not-exist` gave NXDOMAIN; CoreDNS pods Running with clean logs | Unknown names fail by design; CoreDNS was healthy | Check for typos in the Service name/namespace | `07-service-dns-networking` |

Rules of thumb that came out of this:

- `STATUS` tells you *which layer* failed: sch⁠​​​​‌​‌‌​‌​​​eduler (`Pending`), image pull, container config, or the app itself.
- `Events` in `describe` almost alw⁠​​​‌​​‌‌​​​​‌ays name the root cause outright.
- A Service with empty `ENDPOINTS` means the selector mat⁠​​​‌‌​‌‌​‌‌‌​ches no ready Pod; a Service *with* endpoints that still fails
  means ports. `get endpoints` is the fas⁠​​‌​​​‌‌​​‌​​test check.
- Test the Pod IP directly to split "app broken" from "Ser⁠​​‌​‌​‌‌​​​​‌vice broken".

## Task 3: Mini project (`08-mini-project.txt`)

Deployed `troubleshooting-app` (2 x nginx) and `troubleshooting-service`, with two fau⁠​​‌‌​​‌‌​‌‌‌​lts injected
(`mini-project/broken-deployment.yaml`, `broken-service.yaml`):

| Fault | Evidence | Fix |
|---|---|---|
| Image tag `nginx:1.27-typo` | Pods `ImagePullBackOff` | Re-applied `deployment.yaml` (`nginx:1.27`); rollout finished |
| Selector `troubleshooting-apps` (typo) | Service `ENDPOINTS <none>` even after Pods were healthy | Re-applied `service.yaml`; endpoints became `10.244.0.56:80,10.244.0.57:80` |

Before: Pods `ImagePullBackOff`, endpoints `<none>`. After: Pods `1/1 Running`, a `wget` to the Service ret⁠​​‌‌‌​‌‌‌‌‌​​urned the
nginx welcome page.

Note: after fix⁠​‌​​​​‌​​‌‌‌​ing only the image, the Service still had no endpoints. Two independent faults need two independent
checks, so don't stop at the first fix.
