## ALB-Ingress-Controller

EKS creates classic load balancers when we deploy services. Classic load balancers are deprecated and we should be using Application load balancers for our applications. This module will help you configure EKS to provision application load balancers. Read more about load balancers [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/load-balancer-types.html) and [here](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html).

##### Tagging subnets

Tag the subnets in your VPC that you want to use for your load balancers so that the ALB Ingress Controller knows that it can use them.

###### Tags for public subnets:
Public subnets in your VPC should be tagged accordingly so that Kubernetes knows to use only those subnets for external load balancers.

| key                     | value         |
| -------------           | ------------- |
| kubernetes.io/role/elb  | 1             |

###### Tags for private subnets:
Private subnets in your VPC should be tagged accordingly so that Kubernetes knows that it can use them for internal load balancers:

| key                              | value         |
| -------------                    | ------------- |
| kubernetes.io/role/internal-elb  | 1             |

Create an IAM policy called ALBIngressControllerIAMPolicy for your worker node instance profile that allows the ALB Ingress Controller to make calls to AWS APIs on your behalf

```bash
$ aws iam create-policy \
--policy-name ALBIngressControllerIAMPolicy \
--policy-document file://alb-ingress-controller-policy.json
```

Get the IAM role name for your worker nodes. Use the following command to print the aws-auth configmap from where you can fetch the IAM role name:
```bash
$ kubectl -n kube-system describe configmap aws-auth
```

Attach the new ALBIngressControllerIAMPolicy IAM policy to each of the worker node IAM roles:

```bash
$ aws iam attach-role-policy \
--policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/ALBIngressControllerIAMPolicy \
--role-name <WORKER_NODES_IAM_ROLE>
```


Create a service account, cluster role, and cluster role binding for the ALB Ingress Controller:
```bash
$ kubectl apply -f ./rbac-role.yaml
```

Edit `alb-ingress-controller.yaml` file. Replace <VPC_ID>, <EKS_CLUSTER_NAME> & <AWS_REGION> with the corresponding values.

Deploy the ALB Ingress Controller:
```bash
$ kubectl apply -f ./alb-ingress-controller.yaml
```

###### Configure manifest (Option:
Open the ALB Ingress Controller deployment manifest for editing (Optional if alb-ingress-controller.yaml is already configured with vpc and other info).
```bash
 $ kubectl edit deployment.apps/alb-ingress-controller -n kube-system
```

Add the cluster name, VPC ID, and AWS Region name for your cluster after the --ingress-class=alb line and then save and close the file.
```
    spec:
      containers:
      - args:
        - --ingress-class=alb
        - --cluster-name=<EKS_CLUSTER_NAME>
        - --aws-vpc-id=<VPC_ID>
        - --aws-region=<AWS_REGION>
```

Verify that the deployment was successful and the controller started:
```bash
$ kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o alb-ingress[a-zA-Z0-9-]+)
```

##### Deploy Sample Application:

Deploy 2048 game resources:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-namespace.yaml

$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-deployment.yaml

$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-service.yaml
```

Deploy an Ingress resource for the 2048 game:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-ingress.yaml
```

After few seconds, verify that the Ingress resource is enabled:

```bash
$ kubectl get ingress/2048-ingress -n 2048-game
```

After running the above command, an ALB must have been created. You can check the same in AWS console. You should be able to see the following output in the terminal:

```
NAME         HOSTS         ADDRESS         PORTS   AGE
2048-ingress   *    <DNS-Name-Of-Your-ALB>    80     3m
```

Note the DNS name of the ALB created. You can also get the ALB url from AWS console. Hit the url on the browser and enjoy the 2048 game !!

Undeploy the 2048 game:
```bash
$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-namespace.yaml

$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-deployment.yaml

$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-service.yaml

$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/2048/2048-ingress.yaml
```

##### Deploying custom apps with ALB
&nbsp;
```bash
$ kubectl apply -f apps/mywebapp/k8s/deployment.yaml
$ kubectl apply -f apps/mywebapp/k8s/service.yaml
$ kubectl apply -f apps/mywebapp/k8s/ingress.yaml
```

After a few minutes, verify that the Ingress resource was created
```bash
$ kubectl get ingress/mywebapp
```
Note the ALB url and access the app using the same url.



##### Undeploying the app
&nbsp;
```bash
$ kubectl delete -f apps/mywebapp/k8s/ingress.yaml
$ kubectl delete -f apps/mywebapp/k8s/service.yaml
$ kubectl delete -f apps/mywebapp/k8s/deployment.yaml
```