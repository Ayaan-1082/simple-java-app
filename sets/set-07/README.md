# Set 7 - Update a Deployment image

Aim: Update a Deployment image.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-07`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-07`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

Changing the container image changes the Pod template. The Deployment replaces the old Pods with Pods using nginx1.30-alpine.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-07 get deployment web -o jsonpath="{.spec.template.spec.containers[0].image}"
kubectl --context docker-desktop -n k8s-set-07 exec deployment/web -- nginx -v
```

Expected result: the image is nginx:1.30-alpine and nginx reports version1.30.x.

Image tag reference: [Official nginx image](https://hub.docker.com/_/nginx). Rebuilding the job first reapplies the original1.28 image so the update can be demonstrated again.
