# Set 13 Perform and verify a rolling update

Aim: change an image while Kubernetes gradually replaces the old Pods.

Run Set 13. Jenkins first waits for two nginx Pods, changes `nginx:1.28-alpine` to `nginx:alpine`, and waits for the new version. `maxUnavailable: 0` keeps the desired number of ready Pods during the update; `maxSurge: 1` permits one extra Pod.

Expected evidence: rollout status reports success; the Deployment image is `nginx:alpine`; there are two ready new Pods and the old ReplicaSet is scaled to zero. The floating `alpine` tag is used only to make the classroom image change easy to see; a release pipeline should use a fixed version or digest.

Useful demonstration commands:

```powershell
kubectl --context docker-desktop -n k8s-set-13 get pods -w
kubectl --context docker-desktop -n k8s-set-13 rollout history deployment/rolling-web
kubectl --context docker-desktop -n k8s-set-13 rollout undo deployment/rolling-web
kubectl --context docker-desktop -n k8s-set-13 rollout status deployment/rolling-web --timeout=180s
```

Press Ctrl+C to stop watching Pods. The undo commands are an optional rollback demonstration after the pipeline has finished.
