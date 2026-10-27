# Set 11 Integrate GitHub with Jenkins

Aim: check out the latest GitHub commit and automatically deploy the web page stored in that commit.

The prepared job is at <http://localhost:8081>. Its saved defaults use repository <https://github.com/Ayaan-1082/simple-java-app> and branch `kubernetes-practical`. Automatic builds use those saved defaults, so keep them aligned with the repository and branch containing this lab.

1. Push this entire lab folder to your own GitHub repository. The paths in the repository must include `sets/set-11/deployment.yaml`.
2. Open the Set 11 Jenkins job, choose **Build with Parameters**, enter the repository HTTPS URL and branch, and run it once. Use a Jenkins credential ID for a private repository; do not paste a token into the pipeline.
3. The pipeline registers Git polling every two minutes. On later GitHub changes, Jenkins detects a new commit and starts the job. Docker Desktop and Jenkins must stay running.
4. Change the text in `sets/set-11/index.html`, commit, and push. Wait for a build whose cause says SCM change and whose console shows the new commit hash. Jenkins turns the checked out page into a ConfigMap and restarts the nginx Deployment so that its mounted page contains the new code.

The `githubPush()` trigger also supports a GitHub webhook. A GitHub server cannot reach `http://localhost:8081` on your laptop. A webhook needs a reachable Jenkins address ending in `/github-webhook/`. Polling works with a local Jenkins server and does not need a public tunnel.

Verification: the console shows a Git commit hash, a successful rollout, a ready `github-web` Pod in namespace `k8s-set-11`, and the new HTML returned through the Service. To prove automation, keep evidence of the second build triggered after a pushed change. A manual build alone proves checkout and deployment, but does not prove an automatic trigger. To view it in a browser, run `kubectl --context docker-desktop -n k8s-set-11 port-forward service/github-web 8011:80` and open <http://localhost:8011>.

Without a supplied GitHub repository this set is **not run**. Its pipeline stops with that reason.
