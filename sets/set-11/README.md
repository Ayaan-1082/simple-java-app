# Set 11 Integrate GitHub with Jenkins

Aim: check out the latest GitHub commit and automatically deploy its web page.

Open **K8s-Set-11** at [Jenkins](http://localhost:8081) and select **Build with Parameters**. The saved defaults already use `https://github.com/Ayaan-1082/simple-java-app.git`, branch `kubernetes-practical`. The [dedicated branch](https://github.com/Ayaan-1082/simple-java-app/tree/kubernetes-practical) preserves the repository's original Java application on `main` and contains this web practical at its root.

The job checks out the branch, converts `sets/set-11/index.html` into ConfigMap `github-page`, applies the manifests and restarts `github-web` to load the checked-out page. It polls GitHub approximately every two minutes. Docker Desktop and Jenkins must remain running.

To demonstrate automation, change this branch's `sets/set-11/index.html`, commit and push. Keep evidence of the later SCM-triggered build, new commit hash and changed HTML. A manually started build establishes checkout/deployment; its cause alone does not establish automatic triggering. The final [execution report](../../START-HERE.md) contains actual verification results.

```powershell
kubectl --context docker-desktop -n k8s-set-11 get deployment,pods,service -o wide
kubectl --context docker-desktop -n k8s-set-11 exec deployment/github-web -- wget -qO- http://github-web
```

Run [Start-AppAccess.ps1](../../Start-AppAccess.ps1) from the lab root, then open [the deployed page](http://localhost:30011). This starts a local Service port forward because this Docker Desktop cluster does not directly expose NodePorts on Windows localhost. The helper reconnects after a rollout replaces its forwarded Pod.

The declared `githubPush()` trigger supports a webhook, but GitHub cannot reach `http://localhost:8081` on your laptop. A webhook needs a reachable Jenkins address ending `/github-webhook/`. Polling works locally without exposing Jenkins.

When using another repository, push the complete lab folder so `sets`, `app`, `scripts` and Dockerfile are at its root. Update the job/Jenkinsfile parameter defaults for repository, branch and an optional private-repository credential ID. Automatic builds use saved defaults, so do not rely on the previous manual form values. Never paste a token into the Jenkinsfile.
