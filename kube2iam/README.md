## kube2iam

This module will talk you through the iam permissions to the pods. Using kube2iam, we can restrict permissions to AWS resources to each pod individually.

Some useful links:
https://medium.com/merapar/securing-iam-access-in-kubernetes-cfbcc6954de

Attaching assume role policy to Worker nodes IAM role so that it can assume other roles for pods.

Create an IAM policy called kube2iamAssumeRolePolicy for your worker node instance profile

```bash
aws iam create-policy \
--policy-name kube2iamAssumeRolePolicy \
--policy-document file://kube2iam-worker-assume-policy.json
```

Get the IAM role name for your worker nodes from aws-auth configmap. Use the following command to print the aws-auth configmap:
```bash
$ kubectl -n kube-system describe configmap aws-auth
```

Attach the new kube2iamAssumeRolePolicy IAM policy to each of the worker node IAM roles:

```bash
$ aws iam attach-role-policy \
--policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/kube2iamAssumeRolePolicy \
--role-name <WORKER_NODES_IAM_ROLE>
```

We will create an IAM role for pod to access S3 bucket.

Edit `kube2iam-pod-trust-policy.json` file and replace `<AWS_ACCOUNT_ID>` and `<WORKER_NODE_IAM_ROLE>` with appropriate values.

Create empty IAM role with trust policy:

```bash
$ aws iam create-role \
--role-name <POD_ROLE_NAME> \
--assume-role-policy-document file://kube2iam-pod-trust-policy.json
```
For example,

```bash
$ aws iam create-role \
--role-name mywebapp-eks-podS3Role-us-east-1-dev \
--assume-role-policy-document file://kube2iam-pod-trust-policy.json
```

Create IAM policy for S3 access:

```bash
$ aws iam create-policy \
--policy-name mywebappPodS3Policy \
--policy-document file://pod-s3-policy.json
```

Attach policy to the created IAM role:

```bash
$ aws iam attach-role-policy \
--policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/mywebappPodS3Policy \
--role-name <POD_ROLE_NAME>
```

For example,
```bash
$ aws iam attach-role-policy \
--policy-arn arn:aws:iam::00343756723:policy/mywebappPodS3Policy \
--role-name mywebapp-eks-podS3Role-us-east-1-dev
```

Edit `kube2iam-worker-trust-policy.json` file and provide appropriate values for `<AWS_ACCOUNT_ID>` and `<POD_ROLE_NAME>`.

Update trust policy of WorkerNode IAM role:

```bash
$ aws iam update-assume-role-policy \
--role-name <WORKER_NODES_IAM_ROLE> \
--policy-document file://kube2iam-worker-trust-policy.json
```

You can assign different permissions to the pods by attaching different IAM policies to the IAM role for the pod as per your requirement.