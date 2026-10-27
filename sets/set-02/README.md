# Set 2 - Deploy a sample application

Aim: Deploy a sample application.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-02`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-02`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

The Deployment maintains one nginx replica. The ClusterIP Service gives the application a stable internal name and address.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-02 get deployment,pods,service
kubectl --context docker-desktop -n k8s-set-02 port-forward service/web 8002:80
```

Expected result: the Deployment has 1/1 ready replicas. Keep port-forward running and open http://localhost:8002 to see nginx.


