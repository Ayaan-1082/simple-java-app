# Set 9 - Create and mount a PersistentVolumeClaim

Aim: Create and mount a PersistentVolumeClaim.

## Run in Jenkins

The provided Jenkins job is `K8s-Set-09`. Open it and click **Build Now**, then open the build's **Console Output**. For a new job, select Pipeline and use this folder's Jenkinsfile; the complete practical repository must be checked out or copied into its workspace first. The job needs `kubectl` on PATH and a KUBECONFIG that can access context `docker-desktop`.

The pipeline creates or reuses namespace `k8s-set-09`. Its commands are visible in the Jenkinsfile and its manifests are beside it. Each set can run independently.

## What it demonstrates

The PVC requests1Gi from the cluster's default StorageClass. The Pod mounts the claim at /data. The pipeline writes a file, replaces the Pod, and checks that the new Pod can read the same file.

## Verify from PowerShell

```powershell
kubectl --context docker-desktop -n k8s-set-09 get pvc,pod
kubectl --context docker-desktop -n k8s-set-09 exec pvc-demo -- cat /data/proof.txt
```

Expected result: the PVC is Bound, the Pod is Running, and the file still contains stored-through-jenkins after Pod replacement.

This set needs a default dynamic StorageClass. If the claim stays Pending, inspect `kubectl --context docker-desktop get storageclass` and `kubectl --context docker-desktop -n k8s-set-09 describe pvc lab-storage`. Deleting the namespace also deletes its PVC; data retention then depends on the StorageClass reclaim policy.
