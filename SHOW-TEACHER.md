# Show a new Docker image from a Jenkins set

1. Open [practice Jenkins](http://localhost:8081) and run **K8s-Set-06** or another prepared set.
2. In Console Output, show **Build set demonstration image**. It runs a real Docker build and checks the resulting nginx image.
3. Open **Docker Desktop > Images** and search **k8s-set-06**. The new tag is **build-N**, where N is the Jenkins build number. For example, Jenkins build 3 creates `k8s-set-06:build-3`; build 4 creates `k8s-set-06:build-4`. Each image contains its set's exercise files and a JSON record of the set number, build number and creation time.
4. Open **Docker Desktop > Kubernetes > Namespace > k8s-set-06**. The **build-demo** Deployment runs that new image. The final pipeline stage waits for its rollout and reads `/build.json` from the running Pod to check that it returns the current build number.
5. In the Jenkins build page, show **Artifacts > set-image-evidence**. It contains the image ID, creation time, generated Deployment and the build record read from the running Pod.

The same pattern applies to Sets 01 through 15: `k8s-set-NN:build-N`. A successful build now includes the image check and the demonstration rollout, as well as the original exercise checks.

This image-building and `build-demo` Deployment are added demonstration steps requested for the practical. Explain the exercise separately: for example, Set 6's original **web** Deployment scales to three replicas, while **build-demo** shows the newly built image. Set 1's original task is a connection check. The teacher's Java baseline remains the separate **Java-CICD** job.

Docker's **Builds** page also records the image build. Use **Images** when comparing the old and new tags, and use the matching namespace under **Kubernetes** to view the running Pods. A Kubernetes Pod is not an ordinary `docker run` container on the Containers screen.
