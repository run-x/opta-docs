---
title: "k8s-cluster"
linkTitle: "k8s-cluster"
date: 2021-07-21
draft: false
weight: 1
description: Creates an AKS cluster and a default node pool to host your applications in
---

This module creates an [AKS cluster](https://azure.microsoft.com/en-us/services/kubernetes-service/) and a default
node pool to host your applications in. This needs to be added in the environment Opta yml if you wish to deploy services
as Opta services run on Kubernetes.

### Fields

- `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
- `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
- `node_disk_size` -- Optional. The size of disk to give the virtual machines of the nodes. Defaults to 20(GB)
- `node_instance_type` -- Optional. The [Azure virtual machine size](https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs) for the nodes. Defaults
  to Standard_D2_v2.
- `kubernetes_version` -- Optional. The Kubernetes version for the cluster. Must be [supported by AKS](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)
  to bind the cluster too. Gives you automatic K8s version management for the lcuster and node pools. Defaults to "REGULAR"
- `admin_group_object_ids` -- ids of the Active Directory [groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal) to make admins in the K8s cluster.
