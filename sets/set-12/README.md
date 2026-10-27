# Set 12 Build a Docker image and deploy it

Aim: use Jenkins to build a container, run its application tests, and deploy that exact image to Kubernetes.

Run the Set 12 job. The stages build the root Dockerfile, run the Node tests inside the image, render the Kubernetes manifest with a unique image tag, wait for readiness, and request `/health` through the Service.

Open <http://localhost:30012> to see the web application. Verify with:

```powershell
kubectl --context docker-desktop -n k8s-set-12 get deployment,pods,service -o wide
kubectl --context docker-desktop -n k8s-set-12 get deployment lab-app -o jsonpath='{.spec.template.spec.containers[0].image}'
```

This local exercise uses the existing Docker Desktop Kubernetes cluster. The setup checks whether a locally built image can run in that cluster; Docker Desktop versions and image-store settings can affect this. If the cluster cannot see a local image, push it to a registry and use the pushed image name, as in the optional registry mode of Set 15. `imagePullPolicy: IfNotPresent` permits Kubernetes to use an image that is already available to its container runtime.

Expected evidence: tests pass, the image tag contains the Jenkins build number, rollout succeeds, and the Service health check prints `{"status":"ok"}`. A failed test prevents deployment.
