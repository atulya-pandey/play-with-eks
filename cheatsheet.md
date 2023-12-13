## EKS Cheatsheet
&nbsp;

List all eks clusters:
```
$ aws eks list-clusters
```

List all namespaces:
```
$ kubectl get namespace
```

Create a namespace:
```
$ kubectl create namespace <namespace-name>
```

Delete a namespace:
```
$ kubectl delete namespace <namespace-name>
```

Try and learn:
```
$ kubectl get nodes
$ kubectl describe nodes
$ kubectl -n kube-system get services
$ kubectl get pods -n <namespace>
$ kubectl describe pods <pod-name> -n <namespace>
```

Describe a deployed service in yaml format. The output can be manipulated using `yq` tool. Make sure [yq](https://pypi.org/project/yq/) is installed on your machine.
```bash
$ kubectl -n <namespace> get svc <service-name> -o yaml
```

e.g,
```bash
$ kubectl -n <namespace> get svc <service-name> -o yaml | yq .metadata.name
```

Check logs of pod deployments:
```
$ kubectl logs <pod-name> <container-name>
```
If your container has previously crashed, you can access the previous container’s crash log with:

```
$ kubectl logs --previous <pod-name> <container-name>
```

Check logs of metrics-server (if installed):
```
$ kubectl -n kube-system logs $(kubectl get pods --namespace=kube-system -l k8s-app=metrics-server -o name)
```

Check logs of cluster-autoscaler (if installed):
```
$ kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

Put label on a node:
```
$ kubectl label nodes <node-name> <label-key>=<label-value>
$ kubectl get nodes --show-labels
```

Test server:
```
kubectl run -i --tty load-generator --image=busybox /bin/sh
```

Forward service indicated by pod on a port to localhost:
```
$ kubectl --namespace <namespace> port-forward <pod-name> <port>
```

Custom port binding:
```
$ kubectl -n prometheus port-forward prometheus-node-exporter-dcv2t <localhost-port>:<pod-port>
```

Port forwarding on deployments:
e.g, 
```
$ kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090
```

