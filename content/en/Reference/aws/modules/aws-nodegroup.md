---
title: "aws-nodegroup"
linkTitle: "aws-nodegroup"
date: 2021-07-21
draft: false
weight: 1
description: Creates an additional nodegroup for the primary EKS cluster.
---

This module creates an additional nodegroup for the primary EKS cluster. Note that the
`aws-eks` module creates a default nodegroup so this should only be used when
you want one more.

## IAM Permissions given to the Nodegroup
Along with the nodegroup, Opta creates a [AWS IAM role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html)
that is attached to each EC2 in the pool and handles all of the machine's (and Kubernetes actions done by the kubelet
in the machine like, for example, downloading an ecr image) IAM permissions. Opta gives this service account the
following policies:
* AmazonEKSWorkerNodePolicy
* AmazonEKS_CNI_Policy
* AmazonEC2ContainerRegistryReadOnly

The first 2 are needed for the EC2 to function as a k8s node properly and the last ensures we can read ecr images from
this account. If you need more permissions, feel free to attach extra policies to the iam role via the awscli or AWS 
web ui console-- assuming you do not destroy/modify the existing policies attached there should be no problem.

THIS IAM ROLE IS NOT THE ONE USED BY YOUR CONTAINERS RUNNING IN THE CLUSTER-- Opta handles creating appropriate
IAM roles for each K8s service, but for any non-opta managed workloads in the cluster, please refer to this
[AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
(the OIDC provider is created by Opta).

## Taints

Opta gives you the option of adding [taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
to the nodes created in this nodepool. The official documentation gives an excellent detailed summary, but in short
one can use taints to stop workloads from running in said nodes unless they have a matching toleration. Simply provide
a list of such taints as inputs like so:
```yaml
  - type: aws-nodegroup
    name: nodepool1
    min_nodes: 1
    max_nodes: 3
    taints:
      - key: instancetype
        value: memoryoptimized
        effect: "NoExecute"
      - key: team
        value: booking
        # Tolerates for default effect of NoSchedule
      - key: highpriority
        # Tolerates for default value of opta
```

For most cases, simply specifying the `key` should do.

{{% alert title="Warning" color="warning" %}}
Adding taints to nodes also forbids most [daemonsets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
from running in said node. This can be a problem with security/monitoring solutions (e.g. Datadog) which typiclly use
daemonsets to run their agents in each node, so please be careful and read their instructions on how to add
[tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
{{% /alert %}}

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `labels` | labels for the kubernetes nodes | `{}` | False |
| `max_nodes` | Max number of nodes to allow via autoscaling | `15` | False |
| `min_nodes` | Min number of nodes to allow via autoscaling | `3` | False |
| `node_disk_size` | The size of disk to give the nodes' ec2s in GB. | `20` | False |
| `node_instance_type` | The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. | `t3.medium` | False |
| `use_gpu` | Should we expect and use the gpus present in the ec2? | `False` | False |
| `spot_instances` | A boolean specifying whether to use [spot instances](https://aws.amazon.com/ec2/spot/) for the default nodegroup or not. The spot instances will be configured to have the max price equal to the on-demand price (so no danger of overcharging). _WARNING_: By using spot instances you must accept the real risk of frequent abrupt node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes. The former is a graver concern which can be addressed by having multiple node groups of different instance types (see aws nodegroup module) and ideally at least one non-spot.  | `False` | False |
| `taints` | Taints to add to the nodes in this nodegroup. | `[]` | False |