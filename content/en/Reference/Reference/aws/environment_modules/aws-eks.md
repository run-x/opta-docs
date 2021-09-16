---
title: "k8s-cluster"
linkTitle: "k8s-cluster"
date: 2021-07-21
draft: false
weight: 1
description: Creates an EKS cluster and a default nodegroup to host your applications in
---

This module creates an [EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html), and a default
nodegroup to host your applications in. This needs to be added in the environment Opta yml if you wish to deploy services
as Opta services run on Kubernetes.

## Fields

- `max_nodes` - Optional. The maximum number of nodes to be set by the autoscaler in for the default nodegroup. Default 5
- `min_nodes` - Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Default 3
- `node_disk_size` - Optional. The size of disk to give the nodes' ec2s in GB. Default 20
- `node_instance_type` - Optional. The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. Default t3.medium
- `k8s_version` - Optional. The Kubernetes version for the cluster. Must be [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) Default 1.18
- `control_plane_security_groups` - Optional. List of security groups to add to the control plane access. Default []
- `spot_instances` - Optional. A boolean specifying whether to use [spot instances](https://aws.amazon.com/ec2/spot/)
for the default nodegroup or not. The spot instances will be configured to have the max price equal to the on-demand
price (so no danger of overcharging). _WARNING_: By using spot instances you must accept the real risk of frequent abrupt
node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small
risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify
a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes. The former
is a graver concern which can be addressed by having multiple node groups of different instance types (see aws
nodegroup module) and ideally at least one non-spot.
 Default False
- `enable_metrics` - Optional. Enable autoscaling group cloudwatch metrics collection for the default nodegroup. Default False
- `node_launch_template` - Optional. Custom launch template for the underlying ec2s. Default {}

## Outputs

- k8s_endpoint - The endpoint to communicate to the kubernetes cluster through.
- k8s_ca_data - The certificate authority used by the kubernetes cluster for ssl.
- k8s_cluster_name - The name of the kubernetes cluster.
- k8s_openid_provider_url - The openid provider url for AWS IAM <--> Kubernetes RBAC integration.
- k8s_openid_provider_arn - The openid provider arn for AWS IAM <--> Kubernetes RBAC integration.
- k8s_node_group_security_id - The id of the security group of the cluster nodepools.