# Kubernetes practical lab

The lab files cover all fifteen questions. The execution report will be filled with actual Jenkins build results after verification.

1. Start Docker Desktop and wait for Kubernetes.
2. Run `powershell -ExecutionPolicy Bypass -File .\Start-Lab.ps1` from this folder.
3. Open [Jenkins](http://localhost:8081). Read the local login in `../Lab-Login.txt`.
4. Open `K8s-Set-01` through `K8s-Set-15` and choose Build Now or Build with Parameters.
5. Read [the practical guide](PRACTICAL-GUIDE.md) for each question's commands, expected results and viva answers.

This lab uses Jenkins port 8081. Applications use [Set 5](http://localhost:30005), [Set 12](http://localhost:30012) and [Set 15](http://localhost:30015). Browser access depends on the Docker Desktop cluster's NodePort forwarding; internal Service checks are also performed in the pipelines.

GitHub-backed jobs use [the dedicated practical branch](https://github.com/Ayaan-1082/simple-java-app/tree/kubernetes-practical). They check for changes every two minutes. Docker Hub publishing is optional; building and deploying local images uses the current Docker Desktop image store.
