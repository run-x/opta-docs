---
title: "Azure environment modules"
linkTitle: "GCP"
date: 2020-02-01
draft: false
weight: 2
description:
---

## base
This module is the "base" module for creating an environment in azure. It sets up the virtual network, private subnet, 
security groups (and their rules), default encryption key vault, and the container registry. Defaults are set to work 
99% of the time, assuming no funny networking constraints (you'll know them if you have them), so 
_no need to set any of the fields or know what the outputs do_.

*Fields*
* `private_ipv4_cidr_block` -- Optional. This is the cidr block for VM instances in the VPC. Defaults to "10.0.0.0/16"
* `subnet_ipv4_cidr_block` -- Optional. This is the cidr block reserved for the subnet usage by the vm or private links. Defaults to "10.0.0.0/17"

*Outputs*
* vpc_id -- The ID of the [Azure virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) we created for this environment
* private_subnet_id -- The ID of the private [subnet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet)
  we setup for your environment
* acr_id -- The ID of the [Azure container registry](https://azure.microsoft.com/en-us/services/container-registry/) created for this environment
* acr_name --The name of the Azure container registry
* acr_login_url -- The login url of the Azure container registry.

## dns
This module creates an Azure [dns zone](https://azure.microsoft.com/en-us/services/dns/) for
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but SSL support is still incoming.

*Fields*
* domain -- Required. The domain you want (you will also get the subdomains for your use)

*Outputs*
* zone_id -- The ID of the hosted zone created
* name_servers -- The name servers of your hosted zone (very important for the dns setup)
* domain -- The domain again

## k8s-cluster
This module creates an [AKS cluster](https://azure.microsoft.com/en-us/services/kubernetes-service/), and a default
node pool to host your applications in. This needs to be added in the environment opta yml if you wish to deploy services
as opta services run on Kubernetes.

*Fields*
* `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
* `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
* `node_disk_size` -- Optional. The size of disk to give the virtual machines of the nodes. Defaults to 20(GB)
* `node_instance_type` -- Optional. The [Azure virtual machine size](https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs) for the nodes. Defaults
  to Standard_D2_v2.
* `kubernetes_version` -- Optional. The Kubernetes version for the cluster. Must be [supported by AKS](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)
  to bind the cluster too. Gives you automatic K8s version management for the lcuster and node pools. Defaults to "REGULAR"
* `admin_group_object_ids` -- ids of the Active Directory [groups](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal) to make admins in the K8s cluster.

## k8s-base
This module is responsible for all the base infrastructure we package into the opta K8s environments. This includes:
* [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
* [Linkerd](https://linkerd.io/) as our service mesh.
* [Cert Manager](https://cert-manager.io/docs/) for internal ssl.
* A custom load balancer and dns routing built to handle the Ingress Nginx which we set up.

*Fields*
* `nginx_high_availability` -- Optional. Deploy the nginx ingress in a high-availability configuration. Default = false
* `linkerd_high_availability` -- Optional. Deploy the linkerd service mesh in a high-availability configuration for its control plane. Default = false
* `linkerd_enabled` -- Optional. Enable the linkerd service mesh installation. Default =  true
* `nginx_config` -- Optional. Additional configuration for nginx ingress. [Available options](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#configuration-options)

*Outputs*
None
