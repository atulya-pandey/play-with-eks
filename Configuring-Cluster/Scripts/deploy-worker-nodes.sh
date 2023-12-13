#!/usr/bin/env bash

set +x -e


STAGE="dev"
STACK_NAME="mywebapp-eks-worker-nodes-$STAGE"
AWS_REGION="us-east-1"
TEMPLATE_FILE="./amazon-eks-nodegroup.yaml"
# EKS_NODE_AMI_ID="ami-0f2e8e5663e16b436" # Amazon EKS-optimized AMI for Kubernetes version 1.13.7
EKS_NODE_AMI_ID="ami-0e380e0a62d368837" # Amazon EKS-optimized AMI for Kubernetes version 1.12.7
EKS_CLUSTER_NAME="mywebapp-eks-cluster-$STAGE"
EKS_NODE_GROUP="mywebapp-EKS-node-$STAGE"

# INSTANCE_TYPE="t2.micro"  # each t2.micro node can run 4 pods.
INSTANCE_TYPE="t2.small"  # each t2.small can node run 11 pods.

VPC_ID="<VPC-Id>" #default vpc
SUBNET_IDS="<list-of-subnet-ids-comma-separated>" #default vpc

CLUSTER_CONTROL_PLANE_SECURITY_GROUP="<Security-Group-Id>"  # output from cloudformation

stack_parameters="NodeImageId=$EKS_NODE_AMI_ID ClusterName=$EKS_CLUSTER_NAME NodeGroupName=$EKS_NODE_GROUP ClusterControlPlaneSecurityGroup=$CLUSTER_CONTROL_PLANE_SECURITY_GROUP VpcId=$VPC_ID Subnets=$SUBNET_IDS NodeInstanceType=$INSTANCE_TYPE"

aws cloudformation deploy --region $AWS_REGION --template-file $TEMPLATE_FILE \
    --no-fail-on-empty-changeset \
    --parameter-overrides $stack_parameters \
    --capabilities CAPABILITY_NAMED_IAM --stack-name $STACK_NAME
