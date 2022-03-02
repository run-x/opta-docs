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


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `max_nodes` | The maximum number of nodes to be set by the autoscaler in for the default nodegroup. | `5` | False |
| `min_nodes` | The minimum number of nodes to be set by the autoscaler in for the default nodegroup. | `3` | False |
| `node_disk_size` | The size of disk in GB to give the virtual machines of the nodes. | `30` | False |
| `node_instance_type` | The [Azure virtual machine size](https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs) for the nodes. | `Standard_D2_v2` | False |
| `kubernetes_version` | The Kubernetes version for the cluster. Must be [supported by AKS](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions) to bind the cluster too. Gives you automatic K8s version management for the cluster and node pools. | `1.21.9` | False |
| `admin_group_object_ids` | ids of the Active Directory [groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal) to make admins in the K8s cluster. | `[]` | False |
| `service_cidr` | The cidr to be reserved for k8s service usage | `10.0.128.0/20` | False |
| `dns_service_ip` | The ip to use for the internal coredns service | `10.0.128.10` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `k8s_endpoint` | The endpoint to communicate to the kubernetes cluster through. |
| `k8s_ca_data` | The certificate authority used by the kubernetes cluster for ssl. |
| `k8s_cluster_name` | The name of the kubernetes cluster. |
| `client_cert` | Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster. |
| `client_key` | Base64 encoded private key used by clients to authenticate to the Kubernetes cluster. |