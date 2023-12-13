## Autoscaling an EKS Cluster
&nbsp;

#### Horizontal Pod Autoscaler (HPA):
We will be using Helm to install different pacakged on the EKS cluster.

##### Install [Helm](https://docs.aws.amazon.com/eks/latest/userguide/helm.html):
&nbsp;
On Linux:
```bash
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh

$ chmod +x get_helm.sh

$ ./get_helm.sh
```

On Windows:
```powershell
> choco install kubernetes-helm
```

or download the latest release from [here](https://github.com/helm/helm/releases).
Place the exe files in C:\Helm and add it to the path.


Configure Tiller RBAC:
```bash
$ kubectl apply -f ./tiller-rbac.yaml
```

Initialize Helm on both client and server using Tiller Service Account:

```bash
$ helm init --service-account tiller
```

Troubleshooting:

```
Error: could not find a ready tiller pod
```

If the above error comes up, fix using the below command.

```bash
$ helm init --upgrade --service-account tiller
```

##### Install Metrics Server:
&nbsp;
```bash
$ helm install stable/metrics-server --name metrics-server --version 2.0.4 --namespace metrics
```

```bash
$ kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```
After running the above command, check the output. Must be similar to below:
conditions:
  - lastTransitionTime: "2019-07-30T10:38:36Z"
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available

Try some of the below commands to check logs or pods status:
```bash
$ kubectl get pods --namespace=kube-system --selector=k8s-app=metrics-server
$ kubectl get pods --namespace=metrics --selector=k8s-app=metrics-server
$ kubectl -n metrics logs -l app=metrics-server
$ kubectl -n kube-system logs -l app=metrics-server
$ kubectl -n kube-system logs --selector=k8s-app=metrics-server
```
Namespace might vary to kube-system or metrics depending on what was selected during metrics server deployment.



Deploy Apache/PHP:

```bash
$ kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80
```

Autoscale the Deployment:

```bash
$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

Check Status:

```bash
$ kubectl get hpa
```

##### Running Load Test:

Run the following command in a new terminal session:

```bash
$ kubectl run -i --tty load-generator --image=busybox /bin/sh
while true; do wget -q -O - http://php-apache; done
```

In the previous terminal, check hpa status. New pods should get deployed:

```bash
$ kubectl get hpa -w
```

#### Cluster Autoscaler

Find autoscaling group using the AWS Management Console, note the name of the ASG. Edit the ASG's min/max size to 2 and 8 nodes, respectively.

Edit `cluster_autoscaler.yaml`, replacing `<AUTOSCALING_GROUP_NAME>` in line 138 with the ASG name you found in the console. Optionally change the value for `AWS_REGION` in line 141 to something other than `us-east-1` if you are working in a different region.


Create an IAM policy called EKSAutoScalerIAMPolicy for your worker node instance profile:

```bash
$ aws iam create-policy \
--policy-name EKSAutoScalerIAMPolicy \
--policy-document file://asg-policy.json
```

Get the IAM role name for your worker nodes. Use the following command to print the aws-auth configmap.
```bash
$ kubectl -n kube-system describe configmap aws-auth
```

Attach the new EKSAutoScalerIAMPolicy IAM policy to each of the worker node IAM roles

```bash
$ aws iam attach-role-policy \
--policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/EKSAutoScalerIAMPolicy \
--role-name <WORKER_NODES_IAM_ROLE_NAME>
```

Deploy the autoscaler:

```bash
$ kubectl apply -f ./cluster_autoscaler.yaml
```

Watch the logs:

```bash
$ kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

Scale out:

```bash
$ kubectl apply -f ./nginx.yaml
$ kubectl get deployment/nginx-scaleout
$ kubectl scale --replicas=10 deployment/nginx-scaleout
```

#### Cleaning Up

Delete the cluster autoscaler and nginx deployments:

```bash
$ kubectl delete -f ./nginx.yaml
$ kubectl delete -f ./cluster_autoscaler.yaml
```

Delete the horizontal pod autoscaler and load test:

```bash
$ kubectl delete hpa,svc php-apache
$ kubectl delete deployment php-apache load-generator
```