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

For information about the default IAM permissions given to the node group please see
[here](/reference/aws/modules/aws-nodegroup).

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `eks_log_retention` | The retention period (days) for the eks control plane logs. | `7` | False |
| `max_nodes` | The maximum number of nodes to be set by the autoscaler in for the default nodegroup. | `5` | False |
| `min_nodes` | The minimum number of nodes to be set by the autoscaler in for the default nodegroup. | `3` | False |
| `node_disk_size` | The size of disk to give the nodes' ec2s in GB. | `20` | False |
| `node_instance_type` | The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. | `t3.medium` | False |
| `k8s_version` | The Kubernetes version for the cluster. Must be [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) | `1.21` | False |
| `control_plane_security_groups` | List of security groups to add to the control plane access. | `[]` | False |
| `spot_instances` | A boolean specifying whether to use [spot instances](https://aws.amazon.com/ec2/spot/) for the default nodegroup or not. The spot instances will be configured to have the max price equal to the on-demand price (so no danger of overcharging). _WARNING_: By using spot instances you must accept the real risk of frequent abrupt node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes. The former is a graver concern which can be addressed by having multiple node groups of different instance types (see aws nodegroup module) and ideally at least one non-spot.  | `False` | False |
| `enable_metrics` | Enable autoscaling group cloudwatch metrics collection for the default nodegroup. | `False` | False |
| `node_launch_template` | Custom launch template for the underlying ec2s. | `{}` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `k8s_endpoint` | The endpoint to communicate to the kubernetes cluster through. |
| `k8s_ca_data` | The certificate authority used by the kubernetes cluster for ssl. |
| `k8s_cluster_name` | The name of the kubernetes cluster. |
| `k8s_openid_provider_url` | The openid provider url for AWS IAM <--> Kubernetes RBAC integration. |
| `k8s_openid_provider_arn` | The openid provider arn for AWS IAM <--> Kubernetes RBAC integration. |
| `k8s_node_group_security_id` | The id of the security group of the cluster nodepools. |