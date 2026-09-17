- https://github.com/Nency-Ravaliya/Kubernetes 

- k8s core objects: https://github.com/Nency-Ravaliya/Kubernetes/blob/main/core-objects.md

---

# Homework

Core objects, pod lifecycle and rollouts. Ran on minty@homelab. Screenshots are in the screenshots folder.

01-rolling-update.png is deploying v1 then v2 with maxSurge 1 and maxUnavailable 0, which is why there is no downtime.

02-rollout-undo.png is rollout history and rollout undo. The old ReplicaSet is still there at DESIRED 0, which is how undo is instant. Nothing is re-pulled.

03-troubleshooting.png is two broken manifests. selector-mismatch.yaml is rejected by the API server at apply time because the selector must match the template labels. broken-image.yaml is accepted but fails at runtime with ImagePullBackOff, and the old pods keep running.

04-troubleshooting-fix.png is describe pod to read the Events, then rollout undo to fix it. The order is get pods, describe pod, logs, logs --previous.

05-pod-lifecycle.png is all twelve lifecycle files at once: Running, Completed, Error, ErrImagePull, CrashLoopBackOff, and the readiness, liveness and startup probes. The five pod phases are Pending, Running, Succeeded, Failed, Unknown. CrashLoopBackOff and ImagePullBackOff are container states, not phases. The provided 02-pending.yaml asks for 9Gi but this node has 11.5Gi so it schedules, so I added a 32Gi pod to show a real Pending.

06-kubectl-get-tour.png is the get commands: nodes, ns, cluster-info, kube-system pods and events.

07-port-forward.png is port forwarding nginx to localhost:18080. It is a kubectl process tunnel for debugging, not a Service, and it dies with the terminal. I used 18080 because Caddy owns 80 and 443 here.
