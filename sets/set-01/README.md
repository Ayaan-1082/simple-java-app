# Set 1 - Connect Jenkins to Kubernetes

Aim: Connect Jenkins to Kubernetes.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-01`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-01`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

Jenkins runs kubectl with a kubeconfig, which specifies the API server, certificate and authentication. A healthy cluster response and an authorized deployment check establish that the build can reach Kubernetes.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop get nodes
kubectl --context docker-desktop -n k8s-set-01 auth can-i create deployments
```

Expected result: the Docker Desktop node is Ready, and the permission check prints yes. This is a CLI connection; it does not require Kubernetes Cloud agent configuration.


