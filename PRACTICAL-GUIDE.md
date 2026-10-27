# Kubernetes through Jenkins practical guide

Use this guide to run and explain the 15 practical sets. The working files are already arranged by question under [sets](sets). Each folder contains its Jenkinsfile and Kubernetes YAML. Read [START-HERE.md](START-HERE.md) for the final execution results: **expected results below describe what a correct run should show; they do not claim that a set has passed.**

## Start the prepared lab

Your computer already has Docker Desktop 4.96, Java 21, Docker, kubectl and Jenkins installed. The existing Docker Desktop Kubernetes cluster reported version 1.36.1 and a Ready node during setup. Starting the installed Jenkins Windows service was denied, so this practical uses the installed Jenkins WAR with a separate lab home and your current Windows identity.

1. Start Docker Desktop and wait for its engine and Kubernetes cluster.
2. In PowerShell, change to this `kubernetes-practical` folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-Lab.ps1
```

3. Open [the practice Jenkins](http://localhost:8081). Its username is `labadmin`; the generated password is in [Lab-Login.txt](../Lab-Login.txt). Keep that file private.
4. Open a job named `K8s-Set-01` through `K8s-Set-15`. Select **Build Now**, or **Build with Parameters** for Sets 11 and 15. Open the new build, then **Console Output**.

The runtime, logs, credentials and Jenkins workspaces are under `../../work/lab-runtime`, outside this deliverable folder. The launcher copies existing installed Pipeline plugins, prepares the cluster configuration and registers the 15 jobs. Keep this folder in its present location while using the prepared jobs. The launcher needs the existing Jenkins WAR and plugin directory; copying only the lab files to another computer does not install those prerequisites.

The teacher uses Jenkins port 8080; **this lab uses 8081**. Application ports are separate: Set 5 uses 30005, Set 11 uses 30011, Set 12 uses 30012 and Set 15 uses 30015. A browser tab for Jenkins does not itself prove Kubernetes works. This Docker Desktop kind cluster did not forward NodePorts directly to Windows localhost, so `Start-AppAccess.ps1` starts local Kubernetes port forwards for browser access. The Services in Sets 5, 12 and 15 are still NodePort Services. After a rollout replaces the forwarded Pod, rerun `Start-AppAccess.ps1` if the browser connection drops.

For a new computer, install Docker Desktop with its WSL 2 prerequisites, enable/create a Kubernetes cluster, install Java and Jenkins, then add Pipeline, Git, GitHub and credentials-related plugins as needed. Docker Desktop versions differ in their menus: the teacher shows Settings > Kubernetes > Enable; current versions also have a Kubernetes view with **Create cluster**. See [Docker Desktop Kubernetes documentation](https://docs.docker.com/desktop/use-desktop/kubernetes/).

## Understand the connection before the questions

Jenkins runs commands as its agent's Windows user. Your terminal finding a cluster does not automatically give a Windows service the same access. The service can have a different home directory, PATH, Docker permissions and kubeconfig.

In this lab, `Start-Lab.ps1` exports the `docker-desktop` context to the private runtime kubeconfig. Jenkins receives its path through the **KUBECONFIG** environment variable. Every pipeline explicitly selects `--context docker-desktop`; each set uses namespace `k8s-set-NN`. This prevents a command from silently acting in another context or the default namespace. Never upload the runtime kubeconfig, Jenkins home or login file to GitHub.

An alternative for your teacher's installed Jenkins service is to install **Kubernetes CLI**, create a Jenkins **Secret file** credential containing a working kubeconfig, give it ID `kubeconfig`, and wrap Kubernetes steps like this:

```groovy
withKubeConfig([credentialsId: 'kubeconfig', contextName: 'docker-desktop']) {
    bat 'kubectl --context docker-desktop get nodes'
}
```

The agent still needs kubectl installed and access to the cluster endpoint. For Docker builds it also needs Docker engine permission. The plugin supplies a temporary KUBECONFIG; it does not install or start Kubernetes. See the [Kubernetes CLI plugin](https://plugins.jenkins.io/kubernetes-cli/).

Useful terms: an **image** packages the application; a **container** runs it; a **Pod** holds containers; a **Deployment** maintains Pod replicas and updates; a **Service** gives Pods a stable address; a **namespace** separates named resources. Jenkins automates the commands that create and verify these objects.

## First fifteen minutes of practice

Spend the first three minutes opening Jenkins and running Set 1. In the next four, run Sets 2 and 5 and open `http://localhost:30005`. Then run Set 6 and identify three ready Pods. Finish by reading Set 15's stages and explaining checkout -> build -> test -> deploy -> verify. If time permits, practise Set 14 because its troubleshooting commands apply to most failed questions.

For any allotted question: state the aim, show its Jenkinsfile and YAML, run the matching job, show the console and Kubernetes result, then explain the main object. Save evidence of the actual result instead of relying on a green message written into the pipeline.

## Set 1 Configure Jenkins to connect to Kubernetes

**Aim and files:** [Jenkinsfile](sets/set-01/Jenkinsfile) and [namespace.yaml](sets/set-01/namespace.yaml) verify API access from Jenkins. Run **K8s-Set-01**.

The job applies its namespace, prints cluster information and the node, and checks authorization. Repeat these checks in PowerShell if required:

```powershell
kubectl --context docker-desktop cluster-info
kubectl --context docker-desktop get nodes -o wide
kubectl --context docker-desktop -n k8s-set-01 auth can-i create deployments
```

**Expected:** reachable cluster, node Ready and authorization `yes`. An empty Pod list is acceptable here because this question creates no workload.

**Viva:** What is kubeconfig? A file containing cluster endpoint, authentication and context information. What does context select? A cluster, user and optional default namespace.

## Set 2 Deploy a sample application

**Aim and files:** [Jenkinsfile](sets/set-02/Jenkinsfile), deployment, service and namespace YAML in [set-02](sets/set-02). Run **K8s-Set-02**. It applies the manifests and waits for the web Deployment.

```powershell
kubectl --context docker-desktop -n k8s-set-02 rollout status deployment/web --timeout=180s
kubectl --context docker-desktop -n k8s-set-02 get deployment,pods,service -o wide
kubectl --context docker-desktop -n k8s-set-02 exec deployment/web -- wget -qO- http://web
```

**Expected:** completed rollout, ready web Pod and HTML returned through Service `web`. The HTTP check runs inside Kubernetes because the default ClusterIP Service is internal.

**Viva:** Why wait after apply? Accepted configuration can still produce Pods that fail to start. What is a Jenkins stage? A named group of pipeline work, such as deploy or verify.

## Set 3 Create a Pod from YAML

**Aim and files:** [Jenkinsfile](sets/set-03/Jenkinsfile), [pod.yaml](sets/set-03/pod.yaml) and namespace YAML. Run **K8s-Set-03**.

```powershell
kubectl --context docker-desktop -n k8s-set-03 wait --for=condition=Ready pod/yaml-pod --timeout=180s
kubectl --context docker-desktop -n k8s-set-03 get pod yaml-pod -o wide
kubectl --context docker-desktop -n k8s-set-03 exec yaml-pod -- wget -qO- http://127.0.0.1
```

**Expected:** Pod `yaml-pod` is Running with its container ready and returns HTML. YAML identifies `apiVersion`, `kind`, metadata and the desired specification.

**Viva:** Will this standalone Pod be recreated if deleted? No controller maintains it; reapply its YAML. Why use YAML? It records repeatable desired configuration in a file.

## Set 4 Deploy a web application using a Deployment

**Aim and files:** [Jenkinsfile](sets/set-04/Jenkinsfile) and [deployment.yaml](sets/set-04/deployment.yaml). Run **K8s-Set-04**.

```powershell
kubectl --context docker-desktop -n k8s-set-04 rollout status deployment/web --timeout=180s
kubectl --context docker-desktop -n k8s-set-04 get deployment,replicaset,pods -o wide
```

The pipeline also requests the web page inside a selected Pod. **Expected:** the Deployment has its desired ready replicas, a ReplicaSet owns the Pods, and the HTTP request succeeds.

**Viva:** Deployment versus Pod? A Deployment manages replicated Pods through ReplicaSets. What joins a Deployment to its Pods? Matching labels and selectors.

## Set 5 Expose the application through a Service

**Aim and files:** [Jenkinsfile](sets/set-05/Jenkinsfile), [service.yaml](sets/set-05/service.yaml) and Deployment YAML. Run **K8s-Set-05**, then open [the web application](http://localhost:30005).

```powershell
kubectl --context docker-desktop -n k8s-set-05 get service web -o wide
kubectl --context docker-desktop -n k8s-set-05 get endpointslices -l kubernetes.io/service-name=web
kubectl --context docker-desktop -n k8s-set-05 exec deployment/web -- wget -qO- http://web
```

**Expected:** NodePort 30005 routes Service port 80 to the selected Pods' HTTP port, with ready endpoints and a visible nginx page.

**Viva:** Why a Service when Pods have IPs? Pods can be replaced and their IPs change. What selects its backends? The Service selector matches Pod labels.

## Set 6 Scale to three replicas

**Aim and files:** [Jenkinsfile](sets/set-06/Jenkinsfile) and Deployment YAML. Run **K8s-Set-06**. Its key operation and checks are:

```powershell
kubectl --context docker-desktop -n k8s-set-06 scale deployment/web --replicas=3
kubectl --context docker-desktop -n k8s-set-06 get deployment web
kubectl --context docker-desktop -n k8s-set-06 get pods -l app=web -o wide
```

**Expected:** ready count 3/3 and three ready Pods. The job waits for that ready-replica count; temporarily Pending Pods do not establish successful scaling. Reapplying YAML with a different replica count can overwrite this manual scale.

**Viva:** Does scaling build a new image? No, it changes the number of replicas. Which controller maintains the replica count? The Deployment manages a ReplicaSet that maintains the Pods.

## Set 7 Update the Docker image

**Aim and files:** [Jenkinsfile](sets/set-07/Jenkinsfile) and Deployment YAML. Run **K8s-Set-07**. It deploys the original nginx version, then changes its container image.

```powershell
kubectl --context docker-desktop -n k8s-set-07 set image deployment/web nginx=nginx:1.30-alpine
kubectl --context docker-desktop -n k8s-set-07 rollout status deployment/web --timeout=180s
kubectl --context docker-desktop -n k8s-set-07 exec deployment/web -- nginx -v
```

**Expected:** a completed new rollout and the updated nginx version. In `nginx=...`, the left side is the **container name**, not the Deployment name.

**Viva:** What triggers the rollout? Changing the Deployment's Pod template. Why avoid a repeatedly overwritten `latest` tag? An unchanged template may produce no rollout, and the tag does not identify one build.

## Set 8 Deploy using a ConfigMap

**Aim and files:** [Jenkinsfile](sets/set-08/Jenkinsfile), [configmap.yaml](sets/set-08/configmap.yaml), Deployment and Service YAML. Run **K8s-Set-08**.

```powershell
kubectl --context docker-desktop -n k8s-set-08 get configmap web-config
kubectl --context docker-desktop -n k8s-set-08 exec deployment/config-web -- grep "Configured by Jenkins" /usr/share/nginx/html/index.html
kubectl --context docker-desktop -n k8s-set-08 exec deployment/config-web -- wget -qO- http://config-web
```

**Expected:** the ConfigMap supplies the nginx website directory and the returned page includes `Configured by Jenkins`. The image stays separate from this page configuration.

**Viva:** What belongs in a ConfigMap? Nonconfidential configuration. Should passwords go there? Use a Secret and appropriate access controls instead.

## Set 9 Create and mount a PersistentVolumeClaim

**Aim and files:** [Jenkinsfile](sets/set-09/Jenkinsfile), [pvc.yaml](sets/set-09/pvc.yaml) and [pod.yaml](sets/set-09/pod.yaml). Run **K8s-Set-09**.

The job requests 1 GiB through PVC `lab-storage`, mounts it at `/data`, writes a marker, deletes only Pod `pvc-demo`, recreates the Pod and checks the marker again.

```powershell
kubectl --context docker-desktop get storageclass
kubectl --context docker-desktop -n k8s-set-09 get pvc lab-storage
kubectl --context docker-desktop -n k8s-set-09 exec pvc-demo -- cat /data/proof.txt
```

**Expected:** PVC Bound and `stored-through-jenkins` still present after Pod replacement. The manifest relies on the cluster's default StorageClass. Keep the PVC while demonstrating persistence: deleting the namespace/PVC or resetting Docker Desktop may remove the backing data, depending on reclaim behavior. Local persistence is not an external backup.

**Viva:** PVC versus PV? A PVC requests storage; a PV represents provisioned storage. Does ReadWriteOnce mean exactly one Pod? It generally means read-write mounting by one node; multiple Pods on that node can be possible.

## Set 10 Configure a readiness probe

**Aim and files:** [Jenkinsfile](sets/set-10/Jenkinsfile), [deployment.yaml](sets/set-10/deployment.yaml) and Service YAML. Run **K8s-Set-10**. The probe requests `/` on the named HTTP port after two seconds and repeats every three seconds.

```powershell
kubectl --context docker-desktop -n k8s-set-10 get pods -l app=web
kubectl --context docker-desktop -n k8s-set-10 get endpointslices -l kubernetes.io/service-name=web
kubectl --context docker-desktop -n k8s-set-10 exec deployment/web -- wget -qO- http://web
```

**Expected:** ready container and ready Service endpoints after the HTTP probe succeeds. A readiness failure marks the container unready; readiness alone does not restart it. Liveness detects when a restart is needed; startup probes allow initialization time. See [Kubernetes probe documentation](https://kubernetes.io/docs/concepts/workloads/pods/probes/).

**Viva:** Running versus Ready? A running process may still be unable to serve requests. What happens when readiness fails? The Pod stops receiving ordinary Service traffic through ready endpoints.

## Set 11 Automatically deploy GitHub changes

**Aim and files:** [Jenkinsfile](sets/set-11/Jenkinsfile), [index.html](sets/set-11/index.html) and the folder's manifests. This part needs **your GitHub repository**; the prepared files alone do not prove GitHub integration.

Push this whole lab folder so `sets` is at repository root. In **K8s-Set-11**, provide `REPO_URL` and `BRANCH`; use `GIT_CREDENTIALS_ID` for a private repository. First run manually to establish checkout. For unattended runs, configure these repository/branch/credential values as the job's parameter defaults in its pipeline script or Jenkinsfile; do not rely on last-run form values.

The pipeline declares `pollSCM('H/2 * * * *')` and `githubPush()`. Polling checks for changes approximately every two minutes. GitHub cannot deliver a webhook directly to your laptop's localhost. A webhook needs a reachable Jenkins URL ending `/github-webhook/`; polling works while Jenkins stays local.

Change `sets/set-11/index.html`, commit and push. **Expected proof:** a later SCM-triggered build, its new commit hash, successful deployment and changed HTML:

```powershell
kubectl --context docker-desktop -n k8s-set-11 exec deployment/github-web -- wget -qO- http://github-web
```

A manual build proves checkout/deployment; retain the automatic build cause to prove triggering. **Viva:** Polling versus webhook? Jenkins asks Git on a schedule; a webhook sends an event to Jenkins. See [Jenkins Pipeline triggers](https://www.jenkins.io/doc/book/pipeline/syntax/#triggers).

## Set 12 Build a Docker image and deploy

**Aim and files:** [Jenkinsfile](sets/set-12/Jenkinsfile), root [Dockerfile](Dockerfile), [app](app), [Deploy-App.ps1](scripts/Deploy-App.ps1) and the Deployment template. Run **K8s-Set-12**.

Stages select a unique `set12-BUILD_NUMBER` tag, build the image, run `npm test` inside it, then deploy. The helper replaces `__IMAGE__` with the tested tag and checks `/health` through the Service.

```powershell
kubectl --context docker-desktop -n k8s-set-12 rollout status deployment/lab-app --timeout=180s
kubectl --context docker-desktop -n k8s-set-12 get deployment,pods,service -o wide
```

**Expected:** tests pass, Deployment becomes ready and [the sample web app](http://localhost:30012) responds. This local-image mode depends on the prepared Docker Desktop cluster's image store; another cluster may require pushing/loading the image.

**Viva:** Why test the built image? It verifies the package being deployed. What stops deployment after a failed test? A nonzero command status fails the Jenkins stage.

## Set 13 Perform and verify a rolling update

**Aim and files:** [Jenkinsfile](sets/set-13/Jenkinsfile) and [deployment.yaml](sets/set-13/deployment.yaml). Run **K8s-Set-13**. The Deployment has two replicas, `maxUnavailable: 0` and `maxSurge: 1`.

```powershell
kubectl --context docker-desktop -n k8s-set-13 rollout status deployment/rolling-web --timeout=180s
kubectl --context docker-desktop -n k8s-set-13 rollout history deployment/rolling-web
kubectl --context docker-desktop -n k8s-set-13 get deployment,replicaset,pods -o wide
```

**Expected:** updated Pods become ready, old Pods are replaced and the rollout completes. There can temporarily be three Pods. Inspect the Jenkinsfile for the chosen replacement image.

**Viva:** What does maxSurge mean? Extra replicas allowed during replacement. How can a previous revision be restored? `kubectl rollout undo deployment/rolling-web` with the correct context and namespace.

## Set 14 Detect and troubleshoot deployment failure

**Aim and files:** [Jenkinsfile](sets/set-14/Jenkinsfile) and Deployment YAML. Run **K8s-Set-14**. It deliberately deploys an invalid image, detects a failed rollout, confirms an image-pull reason, archives diagnostics and repairs the image.

```powershell
kubectl --context docker-desktop -n k8s-set-14 describe pods -l app=troubleshooting-web
kubectl --context docker-desktop -n k8s-set-14 get events --sort-by=.metadata.creationTimestamp
kubectl --context docker-desktop -n k8s-set-14 rollout status deployment/troubleshooting-web --timeout=180s
```

**Expected:** the console documents ErrImagePull/ImagePullBackOff before recovery, archived evidence files exist, and the repaired rollout succeeds. The intentional intermediate failure is the exercise; a job that merely ignores every error is not a valid demonstration.

**Viva:** Why can logs be empty for an image-pull failure? The application container never started. Where is the pull error? Pod description and events.

## Set 15 Complete GitHub Jenkins Docker Kubernetes CI/CD

**Aim and files:** [Jenkinsfile](sets/set-15/Jenkinsfile), Dockerfile, app tests, deployment helper and template. Run **K8s-Set-15** with `LOCAL_REHEARSAL=true` to rehearse build, tests, two-replica deployment and HTTP verification. This mode explicitly leaves GitHub unverified.

For the complete question, push the whole folder to your repository, set `LOCAL_REHEARSAL=false`, provide repository/branch/credentials, and run. Set these as pipeline parameter defaults for automatic runs. Push an application change and retain the subsequent SCM-triggered build and commit hash.

Docker Hub is optional for local rehearsal. To follow the teacher's registry flow, create your public `k8s-practical-app` repository, add a Jenkins **Username with password** credential named `dockerhub-creds` using your Docker Hub access token as password, enable `PUSH_DOCKERHUB` and enter `DOCKERHUB_NAMESPACE`. The pipeline uses `--password-stdin`; never paste the token into code. Private images additionally require a Kubernetes pull Secret.

```powershell
kubectl --context docker-desktop -n k8s-set-15 rollout status deployment/lab-app --timeout=180s
kubectl --context docker-desktop -n k8s-set-15 get deployment,pods,service -o wide
```

**Expected:** checkout of the pushed commit, passing tests, a unique image tag, two ready replicas, successful Service health check and [the app](http://localhost:30015). A Docker Hub push is proven only when that optional stage actually runs.

**Viva:** CI versus CD? CI builds/tests changes; CD delivers validated changes to an environment. Why unique tags? The deployed version can be tied to a particular Jenkins build.

## Troubleshooting during the practical

Start with the **first failing Jenkins stage**. Copy its command and check the matching namespace.

- **Cannot connect / certificate error:** start Docker Desktop, check `kubectl --context docker-desktop get nodes`, then check Jenkins KUBECONFIG and agent identity. A restarted/reset cluster can require a refreshed export.
- **ImagePullBackOff / ErrImagePull:** describe the Pod; check image name/tag, registry access and pull credentials. A local image in a different engine/store is not available to the cluster.
- **CrashLoopBackOff:** inspect `kubectl logs POD -n NAMESPACE` and `kubectl logs POD -n NAMESPACE --previous`; check command, required configuration and application errors.
- **Pending:** use `describe pod`; check resources, scheduling events and PVC binding. For Set 9, inspect PVC and default StorageClass.
- **Running but 0/1 Ready:** inspect readiness probe path/port and application response. Check EndpointSlices if the Service returns nothing.
- **No resources found:** verify namespace and context before concluding deployment failed. `kubectl get pods` without `-n` only shows the selected namespace.
- **Jenkins cannot find a command:** confirm the agent PATH includes the installed tools; a changed interactive PATH does not update an already running service.

Do not delete namespaces merely to fix a typo; each contains that set's objects, and Set 9's PVC is part of its persistence evidence.

## Corrections to remember from the teacher material

The Node bookstore example needs an actual `kubectl apply` deployment stage; checkout of YAML alone does not deploy. Use the same `.yaml` filename when creating/applying it. Replace the teacher's Docker Hub username with your own. The two sources use different credential IDs; this lab uses `dockerhub-creds` for its optional registry step.

The PDF's Java program only prints text, so its NodePort cannot serve a web page. Maven needs the expected source directory and an executable JAR configuration for `java -jar`; its sample initial commit command also misses a closing quote. These sets use a real HTTP application for web demonstrations. Reapplying an unchanged `latest` image reference is insufficient evidence of an update; show the changed tag, rollout and running application.
