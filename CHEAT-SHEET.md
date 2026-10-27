# Kubernetes Jenkins practical cheat sheet

**Run:** start Docker Desktop -> run `powershell -ExecutionPolicy Bypass -File .\Start-Lab.ps1` -> open [Jenkins](http://localhost:8081) -> run `K8s-Set-NN` -> read **Console Output**. Login is in [Lab-Login.txt](../Lab-Login.txt). See [verified results](START-HERE.md) and [full guide](PRACTICAL-GUIDE.md).

**Browser:** run `powershell -ExecutionPolicy Bypass -File .\Start-AppAccess.ps1` after the application jobs. Open Set 5: [30005](http://localhost:30005), Set 11: [30011](http://localhost:30011), Set 12: [30012](http://localhost:30012), Set 15: [30015](http://localhost:30015). These are local Service port forwards for this cluster; the helper reconnects after Pod replacement.

## Explain the objects

**Image:** application package. **Pod:** container execution unit. **Deployment:** desired replicas and updates, managed through ReplicaSets. **Service:** stable address routing to matching Pod labels. **ConfigMap:** nonsecret configuration. **PVC:** request for persistent storage. **Readiness:** whether a Pod can receive Service traffic. **Namespace:** resource grouping. **Context:** cluster/user selection. Jenkins needs its own working **KUBECONFIG** and tool access.

## Match the question to the demonstration

| Set | Key action | Show the examiner |
|---|---|---|
| 1 | Connect | Ready node, cluster-info, authorization `yes` |
| 2 | Deploy sample | Deployment + Service + successful HTTP request |
| 3 | Pod YAML | `yaml-pod` Running and Ready |
| 4 | Deployment YAML | Deployment -> ReplicaSet -> Pods |
| 5 | Service | NodePort 30005 and ready EndpointSlice |
| 6 | Scale | Deployment `web`, three ready replicas |
| 7 | Update image | New image and completed rollout |
| 8 | ConfigMap | `web-config` mounted, configured HTML |
| 9 | PVC mount | Bound `lab-storage`, file survives Pod replacement |
| 10 | Readiness probe | Probe YAML, ready Pod, Service endpoints |
| 11 | GitHub integration | SCM-triggered build, new commit, changed page |
| 12 | Build and deploy | Docker build -> image tests -> rollout -> HTTP |
| 13 | Rolling update | Two replicas, rollout history, old ReplicaSet zero |
| 14 | Troubleshoot | Detect bad image -> archive events -> repair |
| 15 | Complete CI/CD | GitHub -> build -> test -> deploy -> health check |

Files are under `sets/set-NN/`. Each namespace is `k8s-set-NN`. Keep the two-digit number.

## Commands to remember

Run from the lab root. Example for Set 5; change the namespace and resource names for another set.

```powershell
kubectl --context docker-desktop get nodes
kubectl --context docker-desktop apply -f sets/set-05/namespace.yaml
kubectl --context docker-desktop apply -f sets/set-05/deployment.yaml
kubectl --context docker-desktop -n k8s-set-05 get deployment,pods,service
kubectl --context docker-desktop -n k8s-set-05 rollout status deployment/web
kubectl --context docker-desktop -n k8s-set-05 describe pods
kubectl --context docker-desktop -n k8s-set-05 get events --sort-by=.metadata.creationTimestamp
```

Scale: `kubectl --context docker-desktop -n k8s-set-06 scale deployment/web --replicas=3`.

Image update: `kubectl --context docker-desktop -n k8s-set-07 set image deployment/web nginx=nginx:1.30-alpine`. The left side `nginx` is the container name.

## Common viva and failure answers

**CI:** build/test changes. **CD:** deliver validated changes. `apply` accepting YAML does not prove readiness: wait for rollout and test HTTP. A failed readiness probe removes normal Service traffic; liveness can trigger restarts. A unique image tag identifies a build; unchanged `latest` may not trigger replacement.

**ImagePullBackOff:** inspect Pod events, tag and registry credentials. **CrashLoopBackOff:** inspect `kubectl logs POD -n NAMESPACE --previous`. **Pending:** inspect scheduling/resources/PVC. **Running 0/1:** check readiness path/port. **No resources:** check namespace/context. Preserve Set 9's PVC when replacing its Pod.

**GitHub:** prepared branch is [kubernetes-practical](https://github.com/Ayaan-1082/simple-java-app/tree/kubernetes-practical); original Java `main` is preserved. Sets 11/15 poll approximately every two minutes; Set 15 defaults `LOCAL_REHEARSAL=false`. Localhost cannot receive GitHub webhooks directly. Docker Hub is optional, using Jenkins credential `dockerhub-creds`; never place tokens in code.
