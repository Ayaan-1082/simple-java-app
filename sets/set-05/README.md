# Set 5 - Expose an application with a Service

Aim: Expose an application with a Service.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-05`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-05`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

The Service selector matches the Pods labelled app=web. Its port80 maps to the nginx container port80, and NodePort30005 exposes the Service through the Docker Desktop node.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-05 get service web
kubectl --context docker-desktop -n k8s-set-05 get endpointslices -l kubernetes.io/service-name=web
```

Expected result: the Service reports 80:30005/TCP and an EndpointSlice contains the Pod address. Open http://localhost:30005. If this Docker Desktop version does not forward NodePorts to localhost, run `kubectl --context docker-desktop -n k8s-set-05 port-forward service/web 8005:80` and open http://localhost:8005.


