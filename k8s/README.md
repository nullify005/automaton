# Kubernetes Notes

## PV Issues

Persistent Volumes can get stuck and these need to be almost manually cleared out of the boxes in question:

* `kubectl describe pod <thing> -n <thing>` will tell where why the pod is stuck, which can point to a volume already being attached
* `kubectl scale deploy -n <thing> <thing> --replicas=0` forces scale in to 0 to help unstick
* Manually unmount any volumes and loopback devices on reported hosts with issues so that the PV can be reclaimed
* scale the deploy back up to what it was before and watch it closely

## Draining

```
for n in `kubectl get nodes | grep -v master | grep -v ROLES | grep SchedulingDisabled | awk '{print $1}'`; do echo "===> draining: ${n}"; kubectl drain --delete-local-data --ignore-daemonsets --force --grace-period=30 --timeout=300s ${n}; done
```
