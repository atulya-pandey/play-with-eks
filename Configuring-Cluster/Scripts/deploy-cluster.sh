#!/usr/bin/env bash

set +x -e


STACK_NAME="mywebapp-eks-poc-infrastructure"
STAGE="dev"
AWS_REGION="us-east-1"  # You can choose other region as per your requirement
TEMPLATE_FILE="./amazon-eks-cluster.yaml"
EKS_VERSION="1.12"

VPC_ID="<VPC-Id>" #default vpc
SUBNET_IDS="<subnets-comma-separated>" #default vpc

stack_parameters="VpcId=$VPC_ID SubnetIds=$SUBNET_IDS EKSVersion=$EKS_VERSION"

aws cloudformation deploy --region $AWS_REGION --template-file $TEMPLATE_FILE \
    --no-fail-on-empty-changeset \
    --parameter-overrides $stack_parameters \
    --capabilities CAPABILITY_NAMED_IAM --stack-name $STACK_NAME-$STAGE
