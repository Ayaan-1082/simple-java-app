# Set 6 - Scale a Deployment to three replicas

Aim: Scale a Deployment to three replicas.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-06`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-06`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

The scale command updates the desired replica count. The Deployment creates additional Pods; the pipeline waits until all three are ready.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-06 get deployment web
kubectl --context docker-desktop -n k8s-set-06 get pods -l app=web
```

Expected result: web shows 3/3 ready and three application Pods.


