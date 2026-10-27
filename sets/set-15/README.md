# Set 15 Complete CI CD with GitHub Jenkins Docker and Kubernetes

Aim: a GitHub change causes Jenkins to fetch code, build an image, run tests, deploy two replicas and check the application through its Kubernetes Service.

Open **K8s-Set-15** at [Jenkins](http://localhost:8081) and select **Build with Parameters**. Its saved defaults are repository `https://github.com/Ayaan-1082/simple-java-app.git`, branch `kubernetes-practical`, and `LOCAL_REHEARSAL=false`. The [practical branch](https://github.com/Ayaan-1082/simple-java-app/tree/kubernetes-practical) contains this complete lab. The original Java application on `main` is preserved; this branch builds a small Node.js HTTP sample for the generic web deployment question.

1. Run with the prepared defaults. Jenkins checks out GitHub, builds a unique image, runs its application tests, deploys two replicas and checks `/health` through the Service.
2. Push a visible application change to the practical branch. Jenkins polls approximately every two minutes. Preserve the subsequent SCM-triggered build, commit hash, passing tests, image tag and rollout evidence to demonstrate automatic CI/CD.
3. Run [Start-AppAccess.ps1](../../Start-AppAccess.ps1) from the lab root and open [the application](http://localhost:30015). This Docker Desktop kind cluster needs a local Service port forward for Windows browser access. The helper reconnects after a rollout replaces its forwarded Pod.

The application listens on port 3000 and has a `/health` endpoint. Tests check its page, health response and missing routes. A failed test prevents deployment. Actual verification results are recorded in [START-HERE.md](../../START-HERE.md).

`LOCAL_REHEARSAL` defaults to false. Turn it on explicitly only to test prepared local files without GitHub checkout. A successful rehearsal verifies Jenkins, Docker, tests and Kubernetes, and does not prove GitHub checkout or an automatic trigger. The build description records that distinction.

The default image mode relies on the prepared Docker Desktop cluster being able to run the image built locally by Docker. For Docker Hub as in the teacher's material, create a public `k8s-practical-app` repository in your account, add a Jenkins **Username with password** credential with ID `dockerhub-creds` using your Docker Hub access token as its password, enable `PUSH_DOCKERHUB`, and enter `DOCKERHUB_NAMESPACE`. The pipeline uses `--password-stdin`, pushes the tested tag and removes temporary login configuration. Never put tokens in Git or the Jenkinsfile. Private registry images additionally need a Kubernetes pull Secret referenced by `imagePullSecrets`; this optional mode assumes a public image.

```powershell
kubectl --context docker-desktop -n k8s-set-15 rollout status deployment/lab-app --timeout=180s
kubectl --context docker-desktop -n k8s-set-15 get deployment,pods,service -o wide
```

Expected final state: two ready Pods, the Jenkins image tag in the Deployment, NodePort Service 30015 and a successful HTTP health check. Docker Hub publishing is verified only if its optional stage ran. A local forward lets the browser reach the Service while the NodePort object remains visible in Kubernetes.

When changing repositories, ensure Dockerfile, `app`, `scripts` and `sets` remain at repository root. Update saved parameter defaults, including `LOCAL_REHEARSAL=false`, repository URL, branch and any private-repository credential ID. A reachable Jenkins webhook can use the declared GitHub push trigger; GitHub cannot deliver directly to localhost, so this prepared setup uses polling.
