## Play-With-EKS

This project will help you deploy EKS cluster and different services step by step on the EKS cluster using working code examples.

#### Prerequisites:

* Basic Kubernetes knowledge
* AWS Networking fundamentals and cloudformations

Start with [`Configuring-Cluster`](https://github.com/anidok/EKS-Poc/tree/master/Configuring-Cluster) sub-module to provision the EKS cluster and then you can use other sub-modules to deploy different services on the cluster.

You can look into the [cheatsheet](https://github.com/anidok/EKS-Poc/blob/master/cheatsheet.md) to know some of the basic EKS commands.


#### Things to know
##### Pod Limits:
Choose EC2 type while deploying worker nodes wisely as each pod is allocated a cluster ip and there is a limit on number of IPs for different types of EC2 instances.
https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
&nbsp;
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerEN
