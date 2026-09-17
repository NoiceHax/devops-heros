# Resources

- https://kubernetes.io/docs/tutorials/kubernetes-basics/
- https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download 

- https://kubernetes.io/docs/concepts/architecture/

- https://github.com/Nency-Ravaliya/Kubernetes

---

# Homework

Kubernetes fundamentals and pods. Ran on minty@homelab with minikube. Screenshots are in the screenshots folder.

01-minikube-status.png is minikube version, minikube status and kubectl get nodes. The cluster is one Docker container on the host.

02-handwritten-pod.png is pod.yaml written from memory and applied. Every object has apiVersion, kind, metadata and spec. Pod is v1, but Deployment, ReplicaSet, StatefulSet and DaemonSet are apps/v1.

03-pod-three-stages.png is hello.yml going Pending, ContainerCreating, Running, Completed. busybox runs one echo and exits so it completes. nginx never exits so it stays Running.

04-four-workload-objects.png is Deployment, ReplicaSet, StatefulSet and DaemonSet running together. Deployment makes a ReplicaSet which makes pods. StatefulSet names pods mysql-0, mysql-1, mysql-2 in order. DaemonSet runs one per node.

Reading done: the Kubernetes cluster architecture docs and the course Kubernetes repo linked above.
