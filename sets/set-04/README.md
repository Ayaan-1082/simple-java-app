# Set 4 - Deploy a web application with a Deployment

Aim: Deploy a web application with a Deployment.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-04`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-04`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

A Deployment manages a ReplicaSet, and the ReplicaSet maintains the requested number of Pods. The application uses the standard nginx welcome page.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-04 get deployment,replicaset,pods
kubectl --context docker-desktop -n k8s-set-04 port-forward deployment/web 8004:80
```

Expected result: one available replica and a running Pod. Keep port-forward running and open http://localhost:8004.


