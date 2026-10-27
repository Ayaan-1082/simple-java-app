# Set 15 Complete CI CD with GitHub Jenkins Docker and Kubernetes

Aim: a GitHub change causes Jenkins to fetch code, build an image, run tests, deploy two replicas, and check the web application through its Kubernetes Service.

The prepared Jenkins server is <http://localhost:8081>. The job defaults use repository <https://github.com/Ayaan-1082/simple-java-app>, branch `kubernetes-practical`, and `LOCAL_REHEARSAL=false`. Automatic builds use those saved defaults.

For a complete GitHub run:

1. Push this whole lab folder to your own GitHub repository. The repository root needs the Dockerfile, app, scripts and sets directories.
2. In the Set 15 job, choose **Build with Parameters**. Turn off `LOCAL_REHEARSAL`, enter `REPO_URL`, and use the correct branch. Enter a Git credential ID only for a private repository.
3. Run once to establish the Git checkout and register polling. Push a visible application change. Jenkins polls every two minutes and starts a later build for the changed commit. A reachable Jenkins webhook can also use the registered GitHub push trigger; localhost cannot receive GitHub's webhook directly.
4. Verify the new commit hash in the console, passing application tests, a unique image tag, successful rollout, and `{"status":"ok"}` from the Service check. Open <http://localhost:30015>.

The application has a real HTTP server on port 3000, a `/health` endpoint, and tests for its page, health response and missing routes. An unsuccessful test prevents deployment.

`LOCAL_REHEARSAL` defaults to false for the prepared GitHub repository. Turn it on explicitly only to test the prepared local files without a GitHub checkout. A successful rehearsal verifies Jenkins, Docker, application tests and Kubernetes. It **does not complete or prove the GitHub part**. The build description records that distinction.

The default local image mode relies on the configured Docker Desktop cluster being able to run the image built by Docker. The setup verifies that behavior against the existing cluster. To demonstrate Docker Hub as in the teacher's material, create a public `k8s-practical-app` repository under your account, add a Jenkins **Username with password** credential with ID `dockerhub-creds` using your Docker Hub access token as its password, enable `PUSH_DOCKERHUB`, and enter `DOCKERHUB_NAMESPACE`. The pipeline logs in with `--password-stdin`, pushes the exact tested tag, and removes its temporary login configuration. Never put tokens in Git or the Jenkinsfile.

For a private Docker Hub repository, the Kubernetes namespace additionally needs an image pull Secret referenced by `imagePullSecrets` in the Deployment. The provided registry mode assumes a public image.

Expected final state: two ready Pods, a NodePort Service at port 30015, the Jenkins build image tag in the Deployment, and a successful HTTP check. To prove automatic CI/CD, retain the build started by the pushed GitHub change, including its build cause and commit hash.
