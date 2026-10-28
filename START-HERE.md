# Kubernetes practical lab results and startup

For the teacher's Java example, start with [TEACHER-SETUP.md](TEACHER-SETUP.md) and the **Java-CICD** job on [practice Jenkins port 8081](http://localhost:8081/job/Java-CICD/). The fifteen sets below remain available as independent exercises. The teacher's exact Java source is also saved in `../teacher-java-practical`.

All fifteen sets ran successfully through Jenkins on this computer on 27 October 2026. Sets 11 and 15 also passed automatic builds triggered by an actual pushed GitHub change. The running cluster is Docker Desktop kind, Kubernetes 1.36.1; Jenkins is version 2.580.1 with Java 21.

## Open the prepared lab

Double-click **Open-Jenkins.cmd** in this folder to start the practice server if needed, wait for it to be ready, and open the correct browser address on port 8081. Closing a browser tab does not stop Jenkins. If the server process stops, run this launcher again. Jenkins can open while Docker is stopped; start Docker Desktop before building a Kubernetes set.

**Show a visible change for every build:** every prepared set now builds a real image named **k8s-set-NN:build-N** and rolls it out as **build-demo** in its own namespace. Open **Docker Desktop > Images**, search the set name and show its new build tag. Then choose **Kubernetes > Namespace > k8s-set-NN** to see the new Pod. See [SHOW-TEACHER.md](SHOW-TEACHER.md) for the demonstration. These are added stages alongside each original exercise; the separate teacher Java example remains in `default`.

1. Open [Jenkins](http://localhost:8081). Username: `labadmin`. Your generated local password is in [Lab-Login.txt](../Lab-Login.txt).
2. Open a job named `K8s-Set-01` through `K8s-Set-15`. Choose **Build Now**, or **Build with Parameters** for Sets 11 and 15, then open **Console Output**.
3. Use [the complete practical guide](PRACTICAL-GUIDE.md) for the steps and viva answers. Use [the revision sheet](CHEAT-SHEET.md) for a quick review.

Everything is saved in this folder: `C:\Users\khana\Documents\Codex\2026-10-27\yo\outputs\kubernetes-practical`.

## Start again after a reboot

Start Docker Desktop and wait for Kubernetes to report Ready. Open PowerShell in this lab folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-Lab.ps1
```

Allow Jenkins a minute or two to start, then open port 8081. The launcher also starts browser access for existing application Services. To start browser access separately, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Start-AppAccess.ps1
```

The original Jenkins Windows service now runs on port 8080 and has different accounts. The prepared lab uses the installed Jenkins WAR with a separate home at `../../work/lab-runtime` and consistently listens on localhost port 8081. Use `labadmin` and the password in `../Lab-Login.txt` on port 8081. The launcher checks that an existing instance accepts this account before reusing it. Your original Jenkins jobs remain in their original home. Keep both the output folder and the private runtime folder. The launcher depends on the installed Jenkins WAR/plugins, Java, Docker and kubectl; the ZIP alone is not a fresh-machine installer.

## Verified results

| Set | Exercise | Verified Jenkins build | Result |
| --- | --- | --- | --- |
| 1 | Jenkins cluster connection and authorization | [1](http://localhost:8081/job/K8s-Set-01/1/) | SUCCESS |
| 2 | Sample application deployment and Service HTTP check | [1](http://localhost:8081/job/K8s-Set-02/1/) | SUCCESS |
| 3 | Pod from YAML | [1](http://localhost:8081/job/K8s-Set-03/1/) | SUCCESS |
| 4 | Web application Deployment | [1](http://localhost:8081/job/K8s-Set-04/1/) | SUCCESS |
| 5 | NodePort Service and ready endpoints | [1](http://localhost:8081/job/K8s-Set-05/1/) | SUCCESS |
| 6 | Three ready Deployment replicas | [1](http://localhost:8081/job/K8s-Set-06/1/) | SUCCESS |
| 7 | Docker image update and new nginx version | [1](http://localhost:8081/job/K8s-Set-07/1/) | SUCCESS |
| 8 | ConfigMap mounted as a web page | [1](http://localhost:8081/job/K8s-Set-08/1/) | SUCCESS |
| 9 | PVC mounted in a Pod and data retained after Pod replacement | [1](http://localhost:8081/job/K8s-Set-09/1/) | SUCCESS |
| 10 | HTTP readiness probe | [1](http://localhost:8081/job/K8s-Set-10/1/) | SUCCESS |
| 11 | GitHub change automatically deploys a new page | [2](http://localhost:8081/job/K8s-Set-11/2/) | SUCCESS, SCM change |
| 12 | Docker build, application tests and Kubernetes deployment | [1](http://localhost:8081/job/K8s-Set-12/1/) | SUCCESS |
| 13 | Rolling update, rollout status and history | [1](http://localhost:8081/job/K8s-Set-13/1/) | SUCCESS |
| 14 | Detect image-pull failure, record diagnostics and repair | [1](http://localhost:8081/job/K8s-Set-14/1/) | SUCCESS |
| 15 | Automatic GitHub checkout, Docker build, tests, deployment and HTTP check | [3](http://localhost:8081/job/K8s-Set-15/3/) | SUCCESS, SCM change |

Saved [build results](evidence/jenkins-results.json), console logs and per-namespace resource listings are in [evidence](evidence). The table identifies the recorded verification builds; subsequent pushes may produce additional builds.

The automatic builds checked out commit `21301d14fab77559252ddd938c8f135dcdebc49f` from [the practical branch](https://github.com/Ayaan-1082/simple-java-app/tree/kubernetes-practical). The Set 11 page changed to Version 2. Set 15 built `k8s-practical-app:set15-3`, passed its HTTP application tests, rolled out two ready replicas, returned `{"status":"ok"}` through its Service, and served the Release 2 page. Both build causes say **Started by an SCM change**. The earlier Set 15 build 1 was explicitly a local rehearsal; build 2 verified manual GitHub checkout; build 3 proved the automatic trigger.

## Application links

| Set | Browser URL | What to see |
| --- | --- | --- |
| 5 | [localhost 30005](http://localhost:30005) | nginx welcome page |
| 11 | [localhost 30011](http://localhost:30011) | GitHub-deployed page, Version 2 |
| 12 | [localhost 30012](http://localhost:30012) | Sample web application |
| 15 | [localhost 30015](http://localhost:30015) | Release 2 from the practical branch |

These four URLs returned HTTP 200 during verification. This Docker Desktop kind cluster did not expose NodePorts directly on Windows localhost, so the supplied browser-access script uses local Kubernetes Service port forwards. It maintains them in the background and reconnects after Pod replacement; a rollout may cause a short interruption. The Services in Sets 5, 12 and 15 remain NodePort Services. These browser helpers are separate from Jenkins' internal Service checks.

## GitHub and Docker Hub

The files are published on [Ayaan-1082/simple-java-app, branch kubernetes-practical](https://github.com/Ayaan-1082/simple-java-app/tree/kubernetes-practical). The original `main` branch is preserved. The practical branch uses the small Node HTTP application in `app/`, matching the generic web application questions; the teacher's original Java source is retained in the repository.

Sets 11 and 15 poll the configured branch every two minutes while Jenkins and Docker are running. For another demonstration, edit `sets/set-11/index.html` or `app/server.js`, commit and push to that branch, then show the next SCM-triggered build. A public webhook endpoint is unnecessary for this local setup.

Docker Hub publishing is an optional Set 15 stage and **was not run**. The verified pipelines built Docker images locally and deployed those exact versioned tags through Docker Desktop's image access. To practise Docker Hub, follow the guide and supply your own Docker Hub token through Jenkins credential `dockerhub-creds`. No token or kubeconfig is in the repository or ZIP.
