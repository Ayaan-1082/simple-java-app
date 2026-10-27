# Set 8 - Deploy an application using a ConfigMap

Aim: Deploy an application using a ConfigMap.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-08`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-08`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

A ConfigMap stores non-secret configuration. The Deployment mounts the ConfigMap as files at nginx's document root, so nginx serves the configured HTML.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-08 get configmap web-config -o yaml
kubectl --context docker-desktop -n k8s-set-08 port-forward service/config-web 8008:80
```

Expected result: the page at http://localhost:8008 says Configured by Jenkins. The HTML is supplied by the ConfigMap volume.


