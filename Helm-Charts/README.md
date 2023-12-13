## Deploying applications using Helm charts

This module will guide you through the deployment of k8s apps using Helm charts. Instead of deploying different services individually using kubectl, we will deploy everything all at once.

Some useful links:
https://daemonza.github.io/2017/02/20/using-helm-to-deploy-to-kubernetes/
&nbsp;
https://dzone.com/articles/create-install-upgrade-and-rollback-a-helm-chart-p


Make sure helm is installed and configured. The steps can be found in the beginning of README part of Autoscaling folder.

Initialize Helm on both client and server using Tiller Service Account:

```bash
$ helm init
```
or

```bash
$ helm init --service-account tiller
```

Cd into Helm-Charts directory:

```bash
$ cd Helm-Charts
```

Create skeleton chart:

```bash
$ helm create mywebapp
```

or use the already created directory structure from the repo


Run lint to validate the chart:

```bash
$ helm lint mywebapp
```

Package:

```bash
$ helm package mywebapp --debug
```

The output should be something like below:

```
Successfully packaged chart and saved it to: F:\My Learnings\EKS-Poc\Helm-Charts\mywebapp-0.1.0.tgz
[debug] Successfully saved F:\My Learnings\EKS-Poc\Helm-Charts\mywebapp-0.1.0.tgz to C:\Users\User\.helm\repository\local
```

Deploy:

```bash
$ helm install mywebapp-0.0.1.tgz
```

List deployed packages:

```bash
$ helm ls
```

We should now be able to access our app using the load balancer url.

Kill deployment:

```bash
$ helm delete mywebapp
$ helm del --purge mywebapp
```

#### Using S3 as Helm Chart repository

We can use S3 instead of official Helm to serve as a repository for our helm-charts.

Create a s3 bucket with name **eks-poc-my-helm-charts**. Make sure you have read/write access to the bucket.

##### On Linux
&nbsp;
Install Helm S3 Plugin:
```bash
$ sudo helm plugin install https://github.com/hypnoglow/helm-s3.git
Downloading and installing helm-s3 v0.5.2 ...
Installed plugin: s3
```
**Note: helm-s3 plugin doesn't have windows support as of now. https://github.com/hypnoglow/helm-s3/issues/67**


###### Creating Helm chart repository:
The first thing to do is to turn the my-helm-charts bucket into a valid chart repository. This requires adding an index.yaml to it. The Helm S3 plugin has a helper method to do that for you, which generates a valid index.yaml and uploads it to your S3 bucket:

```bash
$ helm s3 init s3://eks-poc-my-helm-charts/charts
Initialized empty repository at s3://eks-poc-my-helm-charts/charts
```

Add alias for repository:
```bash
$ helm repo add my-charts s3://eks-poc-my-helm-charts/charts
"my-charts" has been added to your repositories
```

Check helm repo list using:

```bash
$ helm repo list
```

##### Uploading the chart to the repository:

Make sure you have already packaged the helm chart as mentioned in the above steps. Push the packaged (.tgz) file using:
```bash
$ helm s3 push ./mywebapp-0.0.1.tgz my-charts
```

Check if the package got deployed to the S3 bucket.

Search the chart from the repository:

```bash
$ helm search mywebapp
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
my-charts/mywebapp    0.0.1           1.0             A Helm chart for Kubernetes
```

Install the chart from the repository:

```bash
$ helm install my-charts/mywebapp
```

##### On Windows

Since helm-s3 doesn't have windows support. The following workaround can be used to pull the helm chart from s3 bucket and then deploy it.

Uploading the chart to s3 using aws cli:
```bash
$ aws s3 cp ./mywebapp-0.0.1.tgz s3://eks-poc-my-helm-charts
upload: .\mywebapp-0.0.1.tgz to s3://eks-poc-my-helm-charts/mywebapp-0.0.1.tgz
```

Downloading the chart from s3 using aws cli:
```bash
$ aws s3 cp s3://eks-poc-my-helm-charts/mywebapp-0.0.1.tgz .
download: s3://eks-poc-my-helm-charts/mywebapp-0.0.1.tgz to .\mywebapp-0.0.1.tgz
```

Deploy the application using the local copy of the chart:

```bash
$ helm install mywebapp-0.0.1.tgz
```