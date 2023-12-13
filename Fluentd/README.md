## Logging to CloudWatch with Fluentd

Create an IAM policy called EKSWorkerLogsPolicy for your worker node instance profile

```bash
$ aws iam create-policy \
--policy-name EKSWorkerLogsPolicy \
--policy-document file://k8s-logs-policy.json
```

Get the IAM role name for your worker nodes from the aws-auth configmap. Use the following command to print the aws-auth configmap

```bash
$ kubectl -n kube-system describe configmap aws-auth
```

Attach the new EKSWorkerLogsPolicy IAM policy to each of the worker node IAM roles

```bash
$ aws iam attach-role-policy \
--policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/EKSWorkerLogsPolicy \
--role-name <WORKER_NODES_IAM_ROLE>
```

The Fluentd log agent configuration is located in the Kubernetes ConfigMap. Fluentd will be deployed as a DaemonSet, i.e. one pod per worker node.

Edit `fluentd.yaml` on line 196, setting the `REGION` and `CLUSTER_NAME` environment variable values.

Apply the configuration:

```bash
$ kubectl apply -f ./fluentd.yml
```

Watch for all of the pods to change to running status:

```bash
$ kubectl get pods -w --namespace=kube-system -l k8s-app=fluentd-cloudwatch
```

We are now ready to check that logs are arriving in CloudWatch Logs.

Select the region that is mentioned in `fluentd.yml` to browse the Cloudwatch Log Group if required.

#### Cleanup

```bash
$ kubectl delete -f ./fluentd.yml
```