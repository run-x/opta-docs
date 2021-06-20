---
title: "GCP environment modules"
linkTitle: "GCP"
date: 2020-02-01
draft: false
weight: 2
description:
---

## base
This module is the "base" module for creating an environment in gcp. It sets up the VPC, private subnet, firewall, 
default kms key, private service access, and activate the container registry. Defaults are set to work 99% of the time, assuming no funny 
networking constraints (you'll know them if you have them), so _no need to set any of the fields or know what the outputs do_.

*Fields*
* `private_ipv4_cidr_block` -- Optional. This is the cidr block for VM instances in the VPC. Defaults to "10.0.0.0/19"
* `cluster_ipv4_cidr_block` -- Optional. This is the cidr block reserved for pod ips in the GKE cluster. Defaults to "10.0.32.0/19"
* `services_ipv4_cidr_block` -- Optional This is the cidr block reserved for service cluster ips in the GKE cluster. Defaults to "10.0.64.0/20"

*Outputs*
* kms_account_key_id -- The id of the [KMS](https://cloud.google.com/security-key-management) key (this is what handles 
  encryption for redis, gke, etc...)
* kms_account_key_self_link -- The self link of the default
  KMS key (sometimes things need the ID, sometimes the ARN, so we're giving both)
* vpc_id -- The ID of the [VPC](https://cloud.google.com/vpc/docs/vpc) we created for this environment
* private_subnet_id -- The ID of the private [subnets](https://cloud.google.com/vpc/docs/vpc#subnet-ranges)
  we setup for your environment

## dns
This module creates a GCP [managed zone](https://cloud.google.com/dns/docs/zones) for
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but in order for this to actually receive traffic you will need to complete
the [dns setup](/miscellaneous/ingress).

*Fields*
* domain -- Required. The domain you want (you will also get the subdomains for your use)
* delegated -- Optional. Set to true once the extra dns setup is complete and it will add the ssl certs.
* subdomains -- Optional. A list of subdomains to also get ssl certs for.

*Outputs*
* zone_id -- The ID of the hosted zone created
* name_servers -- The name servers of your hosted zone (very important for the dns setup)
* domain -- The domain again
* cert_arn -- The arn of the [ACM certificate ](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) which
  is used for ssl.

## k8s-cluster
This module creates an [GKE cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview), and a default
node pool to host your applications in. This needs to be added in the environment opta yml if you wish to deploy services
as opta services run on Kubernetes.

*Fields*
* `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
* `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
* `node_disk_size` -- Optional. The size of disk to give the nodes' ec2s. Defaults to 20(GB)
* `node_instance_type` -- Optional. The [gcloud machine type](https://cloud.google.com/compute/docs/machine-types) for the nodes. Defaults
  to n2-highcpu-4 (highly unrecommended to set to smaller)
* `gke_channel` -- Optional. The GKE K8s [release channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels)
  to bind the cluster too. Gives you automatic K8s version management for the lcuster and node pools. Defaults to "REGULAR"


## k8s-base
This module is responsible for all the base infrastructure we package into the opta K8s environments. This includes:
* [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
* [Linkerd](https://linkerd.io/) as our service mesh.
* A custom load balancer and dns routing built to handle the Ingress Nginx which we set up. 

*Fields*
* `nginx_high_availability` -- Optional. Deploy the nginx ingress in a high-availability configuration. Default = false
* `linkerd_high_availability` -- Optional. Deploy the linkerd service mesh in a high-availability configuration for its control plane. Default = false
* `linkerd_enabled` -- Optional. Enable the linkerd service mesh installation. Default =  true

*Outputs*
None
