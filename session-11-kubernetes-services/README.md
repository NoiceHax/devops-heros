Kubernetes services homework. Ran on minty@homelab with minikube. Screenshots are in the screenshots folder.

01-five-service-types.png is all five service types in one kubectl get svc, with endpoints below. A Service exists because pod IPs change on restart, so it gives a stable name and virtual IP and finds pods by label.

ClusterIP is internal only and is the default. NodePort opens a port 30000-32767 on every node for dev access. LoadBalancer asks a cloud for a real external IP. ExternalName is a CNAME to a name outside the cluster, with no ClusterIP and no endpoints. Headless has clusterIP None and returns pod IPs instead of load balancing, used with StatefulSets.

02-service-dns-proof.png is the difference that matters: the ClusterIP service resolves to one virtual IP, the headless service resolves to three addresses, one per pod.

03-externalname-loadbalancer.png is ExternalName returning its CNAME with no endpoints, and LoadBalancer sitting at pending. Pending is correct here because minikube has no cloud controller to assign an IP, and it still serves traffic through its NodePort. The CNAME target nencyravaliya.me no longer resolves and the lookup still works, because ExternalName is a DNS alias that never checks the target.

04-coredns-fqdn.png is CoreDNS, a pod's /etc/resolv.conf, and the same lookup short and full. The full form is service.namespace.svc.cluster.local. Short names work in the same namespace because of the search list. ndots:5 means names with fewer than five dots try every search domain first, which slows external lookups.

05-blue-green.png runs v1 and v2 side by side then flips the Service selector from slot blue to slot green. Traffic moves instantly because nothing restarts. Cost is running two full copies.

06-canary.png is 9 stable pods and 1 canary behind one Service. Thirty curls gave 29 stable and 1 canary. The split is the replica ratio, not a routing rule.

07-recreate.png is the only strategy with downtime. READY goes 3/3, then 0/3 with curl failing, then v2. Use it when two versions cannot run at once.

08-rs-vs-deployment.png is rollout history working on the Deployment and erroring on the bare ReplicaSet. A ReplicaSet only keeps N pods alive with no revisions or undo. A Deployment manages ReplicaSets and adds that on top.

StatefulSet, DaemonSet and Deployment: Deployment is stateless with random names on any node. StatefulSet has ordered names and keeps its name and storage, for databases. DaemonSet takes no replica count and runs one pod per node, for agents and log collectors.
