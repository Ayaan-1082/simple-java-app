# Set 3 - Create a Pod from YAML

Aim: Create a Pod from YAML.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-03`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-03`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

The Pod manifest describes one nginx container. A direct Pod has no Deployment controller to create a replacement when the Pod object is deleted.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-03 get pod yaml-pod
kubectl --context docker-desktop -n k8s-set-03 describe pod yaml-pod
```

Expected result: yaml-pod shows Running and 1/1 ready.


