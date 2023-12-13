This module helps you bring up the infrastructure for EKS cluster and provision worker nodes.

#### Deploy EKS cluster
```bash
$ sh Scripts/deploy-cluster.sh
```

Once the cloudformation stack has been deployed, check the outputs section of the stack and note down the security group id of the control plane, and provide it to the variable CLUSTER_CONTROL_PLANE_SECURITY_GROUP in Scripts/deploy-worker-nodes.sh.

#### Install kubectl

##### On Windows
Place Kubectl/kubectl.exe in a folder C:/kubectl/bin and add it to the PATH.
Ensure that `kubectl` is in your `PATH`.

##### On Linux:

Kubernetes 1.13:
```bash
$ curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/kubectl
```

Kubernetes 1.12:

```bash
$ curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.9/2019-06-21/bin/linux/amd64/kubectl
```

Kubernetes 1.11:

```bash
$ curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.10/2019-06-21/bin/linux/amd64/kubectl
```

```bash
$ chmod +x ./kubectl
$ mkdir $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
$ echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
```

Verify installation
```bash
$ kubectl version --short --client
```

#### Install aws-iam-authenticator

##### On Windows

Using [chocolatey](https://chocolatey.org/install) package manager
```bash
> choco install -y aws-iam-authenticator
```

##### On Linux 
&nbsp;
```bash
$ curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator

$ chmod +x ./aws-iam-authenticator

$ mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
```

Verify Installation
```bash
aws-iam-authenticator help
```

#### Configure EKS Access

Create or update your kubeconfig for your cluster.

```bash
$ aws eks --region <AWS_REGION> update-kubeconfig --name <eks-cluster-name>
```

Test the configuration.

```bash
$ kubectl get svc
```

##### Provisioning worker nodes
&nbsp;
```bash
$ sh ./Scripts/deploy-worker-nodes.sh
```

This will launch the cloudformation stack to deploy the worker node EC2 instances.
Note the InstanceRole Arn and place in config/aws-auth-cm.yaml.

```bash
$ kubectl apply -f ./aws-auth-cm.yaml
$ kubectl get nodes --watch
```

This will enable worker nodes to join the eks cluster. Wait till all the nodes are ready. 

#### Deploying the sample app
Push the Docker image of the app to the ECR repo, copy the image url and paste in apps/mywebapp/k8s/deployment.yaml. 

Note: In this case, the app runs on port 80, hence all the security has been configured for that port. You might want to tweak the configurations in case your app uses a different port.

Create the deployments and services.

```bash
$ kubectl apply -f apps/mywebapp/k8s/deployment.yaml
$ kubectl apply -f apps/mywebapp/k8s/service.yaml 
```

This will create the pods and create a load balancer to access the pods. App can be accessed if atleast one Ec2 inside load balancer is up. Check the app using the ELB url.

#### Undeploy the Applications

To delete the resources created by the applications, we should delete the application services and deployments:

```bash
$ kubectl delete -f apps/mywebapp/k8s/deployment.yaml
$ kubectl delete -f apps/mywebapp/k8s/service.yaml
```

#### Kubernetes Dashboard

Deploy the dashboard.
```bash
$ kubectl create -f Configuring-Cluster/kubernetes-dashboard.yaml
```


##### Service Accounts
Create admin service account for privileaged access to the dashboard.

```bash
$ kubectl apply -f ./eks-admin-service-account.yaml
$ kubectl apply -f ./eks-admin-cluster-role-binding.yaml
```

Get an authentication token.

```bash
aws-iam-authenticator token -i <eks-cluster-name> --token-only
```
Copy the token to the clipboard that will be used to access k8s dashboard later on.

```bash
$ kubectl proxy &
```

Now, browse to: <http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/> and use the token to login into the dashboard.

##### Install Heapster and Influx
&nbsp;
```python
def implement_heapster_influx():
    pass
```

#### Configure EKS Access

By default, only the IAM user/role which creates the EKS cluster has the access to the EKS control plane. However, we can add other IAM users/roles to access an Amazon EKS cluster

##### aws-auth ConfigMap snippet
&nbsp;
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<AWS::AccountId>:role/<ROLE_NAME1>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
```

Open the aws-auth ConfigMap.

```bash
$ kubectl edit -n kube-system configmap/aws-auth
```

Add the IAM role/user to you want to provide access to and save the file.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<AWS_ACCOUNTID>:role/<ROLE_NAME1>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::<AWS_ACCOUNTID>:role/<ROLE_NAME2>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::<AWS_ACCOUNTID>:user/<IAM_USER_NAME1>
      username: <IAM_USER_NAME1>
      groups:
        - system:masters
    - userarn: arn:aws:iam::<AWS_ACCOUNTID>:user/<IAM_USER_NAME2>
      username: <IAM_USER_NAME2>
      groups:
        - system:masters
```