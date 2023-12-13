## EKS Cluster Monitoring

Links: 
https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
https://eksworkshop.com/monitoring/


#### Deploying Prometheus:

##### Method1 (Using pre-existing helm-charts)
&nbsp;
Create a Prometheus namespace:

```bash
$ kubectl create namespace prometheus
```

Deploy prometheus:

```bash
$ helm install stable/prometheus \
--name prometheus \
--namespace prometheus \
--set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"
```

Verify that all of the pods in the prometheus namespace are running.

```bash
$ kubectl get pods -n prometheus
```

You can access the prometheus in localhost using port-forward:
```bash
$ kubectl --namespace prometheus port-forward <prometheus-server-pod-name> 9091
```
 Make sure prometheus is running on port 9091. If it's running on a different port, provide that port value.

##### Method2 (Using custom k8s deployment file)
&nbsp;
Provision Storage Class:

Note: This method is applicable only when worker nodes have been deployed in public subnets.

```bash
$ kubectl create -f ./prometheus-storageclass.yaml
```

Configure prometheus-values.yaml and provide external IPs of one of the worker nodes in line 726.

```bash
$ helm install -f ./prometheus-values.yaml stable/prometheus --name prometheus --namespace prometheus
```

Check if Prometheus components deployed as expected:

```bash
$ kubectl get all -n prometheus
```
By running this, you should be able to see all the Prometheus pods, services, daemonsets, deployments, and replicasets are all ready and available.


You can access Prometheus server URL by going to any one of your Worker node IP address and specify port `:30900/targets` (for ex, `52.12.161.128:30900/targets`. Remember to open port 30900 in your Worker nodes Security Group. In the web UI, you can see all the targets and metrics being monitored by Prometheus

##### Method3 (Using ELB)
&nbsp;
Provision Storage Class:

```bash
$ kubectl create -f ./prometheus-storageclass.yaml
$ helm install -f ./prometheus-values-elb.yaml stable/prometheus --name prometheus --namespace prometheus
```

Check if Prometheus components deployed as expected:

```bash
$ kubectl get all -n prometheus
```

Get Prometheus ELB Url:
```bash
$ export ELB=$(kubectl get svc -n prometheus prometheus-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

$ echo "http://$ELB"
```

You can access Prometheus server URL using ELB url.
for ex, `<ELB-url>/targets`


#### Deploying Grafana

Create grafana Namespace:

```bash
$ kubectl create namespace grafana
```

Deploy grafana:

```bash
helm install stable/grafana \
    --name grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set adminPassword="EKS!sAWSome" \
    --set datasources."datasources\.yaml".apiVersion=1 \
    --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
    --set datasources."datasources\.yaml".datasources[0].type=prometheus \
    --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.prometheus.svc.cluster.local \
    --set datasources."datasources\.yaml".datasources[0].access=proxy \
    --set datasources."datasources\.yaml".datasources[0].isDefault=true \
    --set service.type=LoadBalancer

```
Check if Grafana components are deployed as expected:

```bash
$ kubectl get all -n grafana
```

Get Grafana ELB Url:

```bash
$ export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

$ echo "http://$ELB"
```

Login using ELB url with username `admin` and generate password using below command.

```bash
$ kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Create dashboards using dashboard id 3131 (to monitor nodes) & 3146 (to monitor pods).

Undeploy:

```bash
$ helm delete prometheus
$ helm del --purge prometheus
$ helm delete grafana
$ helm del --purge grafana
```