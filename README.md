# Kubernetes practical through Jenkins

Fifteen independent lab exercises for a Windows computer running Docker Desktop Kubernetes and Jenkins.

Read [START-HERE.md](START-HERE.md) for setup and execution results, then [PRACTICAL-GUIDE.md](PRACTICAL-GUIDE.md) for the steps, verification commands and viva answers, or use [CHEAT-SHEET.md](CHEAT-SHEET.md) for quick revision. Each folder under [sets](sets) contains one question's Jenkinsfile and manifests.

The root Jenkinsfile runs Set 15. GitHub-backed sets use the `kubernetes-practical` branch of `https://github.com/Ayaan-1082/simple-java-app.git`. The original Java example is retained in that repository; this branch's Dockerfile builds the small HTTP application in `app/` for the web deployment exercises.

`Start-Lab.ps1` starts the installed Jenkins WAR on localhost port 8081 using a separate lab home. It needs installed Jenkins Pipeline/Git/GitHub plugins and a working `docker-desktop` cluster. It does not install these prerequisites on a fresh machine.

Local passwords, kubeconfig and runtime files are outside the repository. Keep them private. See the practical guide for Jenkins Secret file credentials when using a Windows service or another agent.

Run [Start-AppAccess.ps1](Start-AppAccess.ps1) after the application jobs to enable browser access on ports 30005, 30011, 30012 and 30015. This cluster needs local Service port forwards; the helper reconnects after a rollout replaces its forwarded Pod.
