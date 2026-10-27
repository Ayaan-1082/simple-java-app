# Set 10 - Configure a readiness probe

Aim: Configure a readiness probe.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-10`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-10`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

Kubernetes sends an HTTP request to / on the named http port. A successful probe makes the container ready; Services route application traffic to ready endpoints. A failing readiness probe removes the Pod from normal Service traffic without restarting its container.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-10 describe deployment web
kubectl --context docker-desktop -n k8s-set-10 get pods -l app=web
kubectl --context docker-desktop -n k8s-set-10 get endpointslices -l kubernetes.io/service-name=web
```

Expected result: the readiness probe is HTTP GET /, the Pod is1/1 ready, and the Service has a ready endpoint.


