# Teacher Kubernetes setup

This guide follows the supplied **Jenkin-Docker-Kuber.pdf** Java workflow. The supplied **Kubernets.docx** describes a separate Node.js bookstore workflow, documented at the end. Keep their application names, ports and credential IDs distinct.

On 28 October 2026, **Java-CICD build 1 completed successfully** from the repository's `main` commit `b16441dc2f472924524e3117917dbe0a66801102`. Jenkins ran Maven, built the Java image, authenticated and pushed it to Docker Hub, and applied the teacher manifest. Independent verification confirmed two Ready Java Pods, `java-service` NodePort 30008, and the teacher's console messages. Evidence is saved in `../teacher-java-practical/evidence`. A stalled initial layer transfer was recovered with Docker Buildx using the same Dockerfile; the unchanged Jenkins pipeline then finished successfully. The fifteen separate exercise jobs remain available alongside this Java baseline.

## The exact Java baseline

Use [Ayaan-1082 simple-java-app on main](https://github.com/Ayaan-1082/simple-java-app/tree/main). Its files already follow the PDF and include the small Maven corrections needed to produce an executable JAR.

| Item | Teacher-aligned value |
| --- | --- |
| Source branch | `main` |
| Jenkins job | `Java-CICD` |
| Prepared Jenkins address | `http://localhost:8081` (PDF uses 8080) |
| Language and build | Java 17 target, Maven |
| Source file | `src/main/java/App.java` |
| Build output | `target/simple-java-app-1.0.jar` |
| Docker base image | `eclipse-temurin:17-jdk` |
| Docker Hub image | `robustcoder/java-app:latest` |
| Jenkins Docker Hub credential | `dockerhub-creds` |
| Kubernetes context | `docker-desktop` |
| Kubernetes namespace | `default` |
| Deployment and container | `java-app` |
| Replicas | `2` |
| Service | `java-service` |
| Service ports | `80` -> target `8080`; NodePort `30008` |

The PDF uses placeholders for GitHub and Docker Hub accounts. The repository and image above use the existing student project values instead. The image must be pushed using an account authorized to write to `robustcoder/java-app`; a repository name does not supply registry permission.

## Start Docker Desktop and find Kubernetes

On 28 October 2026, the dashboard's **Unable to retrieve latest data from the cluster** error was caused by a missing `C:\Users\khana\.kube\config`. The command-line client had been using a different home folder. The working Docker Desktop configuration was restored to the standard user folder, and Docker Desktop was restarted. Its dashboard then showed the active cluster and `desktop-control-plane` as **Ready**. Cluster resources were preserved.

1. Open **Docker Desktop** from Windows Start. Wait for its engine to finish starting. Docker must remain running while Jenkins builds images and while its local Kubernetes cluster is used.
2. In the installed Docker Desktop 4.96 interface, open **Kubernetes in the left sidebar**. The teacher's screenshot/text refers to the older Settings > Kubernetes > Enable Kubernetes layout. The sidebar is the corresponding current entry point.
3. If no cluster exists, use **Create cluster**, select the intended Docker Desktop cluster settings, and create it. If a cluster already exists, inspect/start that cluster and wait for it to become ready.
4. Select the **default namespace** when looking for the teacher's `java-app` and `java-service`. The former 15-set package used namespaces named `k8s-set-01` through `k8s-set-15`; those resources appear under their own namespaces or an all-namespaces view.
5. In PowerShell, verify both Docker and Kubernetes:

```powershell
docker version
kubectl --context docker-desktop get nodes
kubectl --context docker-desktop -n default get deployment,pods,service
```

**Expected:** `docker version` includes a Server section and the Kubernetes node reports Ready. Initially there may be no `java-app` because enabling the cluster alone does not deploy the application. The built-in `kubernetes` Service is normal.

If the Docker engine is stopped, a missing Kubernetes workload or a failed connection is not evidence that the YAML is wrong. Start Docker Desktop first, wait, then repeat the checks. The cluster may take longer than the dashboard window to start. Do not reset a cluster merely because a namespace view is empty.

See [Docker Desktop Kubernetes navigation](https://docs.docker.com/desktop/use-desktop/kubernetes/) for the current interface and [Kubernetes namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the resource scope.

## Check Java Maven and the existing source

The PDF asks for a folder named `simple-java-app`. Use a checkout of the existing repository's `main` branch. Run build commands from its root, where `pom.xml` and Dockerfile are located. An existing checkout should be inspected before changing branches so local changes are preserved.

```powershell
java -version
mvn -version
mvn clean package
```

The installed Maven command is at `C:\Users\khana\tools\apache-maven-3.9.9\bin\mvn.cmd`. The host Java 21 can compile this project's Java 17 target; the Dockerfile uses the teacher's Java 17 runtime image.

The exact PDF application is a console program:

```java
public class App {
    public static void main(String[] args) throws Exception {
        System.out.println("Java CI/CD Application Started...");
        while (true) {
            Thread.sleep(5000);
            System.out.println("Hello from Java CI/CD Pipeline!");
        }
    }
}
```

Keep it at `src/main/java/App.java`, Maven's expected source location. The existing `main` POM already includes Java 17 compiler settings and the JAR manifest entry `Main-Class: App`. This is a necessary correction to the PDF, whose printed POM does not make `java -jar` executable. A successful build should produce `target/simple-java-app-1.0.jar`.

The Dockerfile remains the teacher's:

```dockerfile
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY target/simple-java-app-1.0.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

## Configure the teacher Jenkins pipeline

Open **http://localhost:8081**. The original Jenkins Windows service now occupies the PDF's port 8080 and has different accounts. The practice launcher therefore consistently uses 8081, retaining the prepared account, fifteen sets and `Java-CICD`. The Java job uses the repository's `main:Jenkinsfile`; its build and deployment steps are unchanged by the Jenkins port. The installed Jenkins WAR runs as the current user with the existing practice home.

In **Manage Jenkins > Plugins**, ensure the teacher's Docker, Docker Pipeline and Kubernetes CLI plugins are available, together with Pipeline, Git and credential support required by the Jenkinsfile. Plugins do not replace the Docker engine, Maven or kubectl executables.

In **Manage Jenkins > Credentials > System > Global credentials**, create/verify:

- Kind: **Username with password**.
- Username: the authorized Docker Hub username.
- Password field: the corresponding Docker Hub access token.
- ID: **dockerhub-creds**.

Never paste a token into a Jenkinsfile or GitHub. The PDF's `docker login -p` command should use `--password-stdin`; the existing main Jenkinsfile already uses that correction.

Create/open Pipeline job **Java-CICD**. Use the existing repository, branch `main`, and its root `Jenkinsfile` through **Pipeline script from SCM**, or paste the same script as the PDF instructs. Its stages are:

1. Clone `https://github.com/Ayaan-1082/simple-java-app.git`, branch `main`.
2. Run `mvn clean package`.
3. Run `docker build -t robustcoder/java-app:latest .`.
4. Bind `dockerhub-creds`, log in with `--password-stdin`, and run `docker push robustcoder/java-app:latest`.
5. Run `kubectl apply -f deployment.yaml`.

Docker Hub push is part of this teacher workflow. A local image build by itself does not complete that stage.

The Jenkins agent needs the installed tools and a kubeconfig it can read. A Windows service can run under a different account from your terminal. The existing main Jenkinsfile sets the Maven path and `KUBECONFIG=C:\Users\khana\.kube\config`; verify that access from the actual agent. Alternatively, the teacher's Kubernetes CLI plugin can bind a Jenkins Secret file kubeconfig using `withKubeConfig`. Installing the plugin alone does not establish a connection. See [Kubernetes CLI plugin instructions](https://plugins.jenkins.io/kubernetes-cli/).

## Apply the exact Deployment and Service

The existing root `deployment.yaml` follows this PDF structure:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: java-app
  template:
    metadata:
      labels:
        app: java-app
    spec:
      containers:
      - name: java-app
        image: robustcoder/java-app:latest
---
apiVersion: v1
kind: Service
metadata:
  name: java-service
spec:
  type: NodePort
  selector:
    app: java-app
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30008
```

There is no namespace field in the teacher YAML. Explicitly select `default` in commands so the resources appear where expected:

```powershell
kubectl --context docker-desktop -n default apply -f deployment.yaml
kubectl --context docker-desktop -n default rollout status deployment/java-app --timeout=180s
kubectl --context docker-desktop -n default get deployment,pods,service
kubectl --context docker-desktop -n default logs deployment/java-app --tail=10
```

**Expected:** two running Java Pods, `java-service` reporting `80:30008/TCP`, and the teacher's repeated Java messages in the logs. In Docker Desktop > Kubernetes, select `default` to inspect the same resources.

When Jenkins rebuilds and pushes the same `latest` tag, an unchanged Deployment file may not replace existing Pods. After the push/apply, add the following minimal update check:

```powershell
kubectl --context docker-desktop -n default rollout restart deployment/java-app
kubectl --context docker-desktop -n default rollout status deployment/java-app --timeout=180s
```

This retains the teacher's image name while making a fresh rollout explicit. A successful `apply` or a printed success sentence alone is not sufficient verification.

## The PDF program and browser access

**Preserve the exact console program for the baseline the teacher supplied.** It is verified through Pod status and Java logs. It does not contain an HTTP server and does not listen on 8080. Creating the Service does not add one. Consequently, a browser request to `http://localhost:30008` cannot return a web page from that exact program.

For questions that explicitly require a web application or HTTP readiness probe, the necessary extension is a small **Java HTTP listener on port 8080**, keeping class `App`, Maven, the JAR, Dockerfile, image and Service names. Document that as the web question's extension. It is not necessary to replace the teacher project with Node.js or nginx.

Docker Desktop's cluster may also require a local Service port forward for a Windows browser, but forwarding only works if the application actually serves HTTP. If an HTTP-enabled Java version is deployed, a foreground check is:

```powershell
kubectl --context docker-desktop -n default port-forward service/java-service 30008:80
```

Keep it running and open port 30008. A port forward is a local access method; it does not change the teacher's NodePort Service or fix a missing listener.

## Separate DOCX bookstore workflow

**Kubernets.docx is a different application example.** It uses [Agilelab online-book-store-](https://github.com/Agilelab/online-book-store-), Node.js, `node:18`, `npm install`, and `node server.js` on port 3000. Its Dockerfile is not the Java Dockerfile.

| Item | DOCX value |
| --- | --- |
| Application | Online Book Store |
| Node tool in Jenkins | `NodeJS_18` |
| Image shown in teacher example | `saharsh1211/online-book-store:latest` |
| Jenkins Docker Hub credential ID | `dockerhub-cred` singular |
| Deployment | `online-book-store`, two replicas |
| Service | `online-book-store-service` |
| Service ports | `80` -> target `3000`; NodePort `30007` |

Use the student's authorized Docker Hub namespace when carrying out that separate example; the teacher's printed username is not permission to push into their account. The Jenkins `NodeJS_18` tool must exist if retaining its `tools` block.

Its printed Jenkins stages checkout code, install dependencies, build the Docker image, log in and push. They omit the actual Kubernetes apply stage. Add `kubectl apply -f deployment.yaml` and a rollout check when implementing that document's deployment. The text later says `deployment.yml`; use the actual filename consistently. Docker Hub stores images; the Kubernetes resource view is in **Docker Desktop**, not Docker Hub.

For the requested Java baseline, continue using `main`, `java-app`, `java-service`, `dockerhub-creds` and port 30008. Do not mix the DOCX bookstore image/port/credential ID into it.

## If the teacher-aligned run fails

- **Docker cannot connect:** start Docker Desktop; confirm `docker version` shows the Server before rebuilding.
- **Kubernetes cannot connect:** wait for the cluster and check `kubectl --context docker-desktop get nodes`; then verify Jenkins uses the same working kubeconfig.
- **No Java resources in Docker Desktop:** select `default`; run `kubectl --context docker-desktop -n default get deployment,pods,service`. An empty view is different from a stopped cluster.
- **ImagePullBackOff:** describe the Java Pods and inspect events; check the exact image name/tag, Docker Hub push result and image visibility.
- **CrashLoopBackOff:** inspect `kubectl --context docker-desktop -n default logs deployment/java-app`; verify Maven produced an executable JAR. For a specific restarting Pod also inspect logs with `--previous`.
- **Jenkins push fails:** check `dockerhub-creds` in that same Jenkins instance and registry write permission. Keep the token private.
- **Service exists but browser fails:** the baseline console application has no HTTP listener. Check that before changing Service ports or assuming cluster failure.
