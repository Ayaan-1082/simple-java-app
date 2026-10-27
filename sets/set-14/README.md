# Set 14 Detect and troubleshoot a failed deployment

Aim: make Jenkins detect a deployment problem, capture its cause, repair the configuration, and prove recovery.

Run Set 14. The manifest deliberately references an image that does not exist. The first rollout is expected to fail after about 45 seconds. Jenkins checks for `ErrImagePull` or `ImagePullBackOff`, saves deployment descriptions, Pod details and events as build artifacts, replaces the bad image with nginx, and waits for a healthy rollout.

The overall build passes only when the expected image-pull fault was detected and the repaired Deployment became ready. A cluster connection error is not accepted as proof of the intended fault.

In the Jenkins build, open **Artifacts** and inspect the three `set14-*.txt` files. Events should identify the failed image pull. The final namespace `k8s-set-14` should have a ready nginx Pod.

For a real failure, use `kubectl describe pod`, `kubectl get events`, and `kubectl logs POD_NAME`. An image-pull failure occurs before the container starts, so application logs are usually unavailable. `CrashLoopBackOff` instead indicates a container that starts and repeatedly exits; inspect `kubectl logs POD_NAME --previous` for that case.
