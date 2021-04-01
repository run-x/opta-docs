---
title: "Environment Modules"
linkTitle: "Environment Modules"
weight: 9
description: >
  Input and output of different Environment Modules
---

# Environment Module Types
Here is the list of module types for the user to use in an environment opta yaml (a root one with no environments on 
top specified), with their inputs and outputs:

# AWS

## aws-base
This module is the "base" module for creating an environment in aws. It sets up the VPCs, default kms key and the
db/cache subnets. Defaults are set to work 99% of the time, assuming no funny networking constraints (you'll know them
if you have them), so _no need to set any of the fields or no what the outputs do_.

*Fields*
* `total_ipv4_cidr_block` -- Optional. This is the total cidr block for the VPC. Defaults to "10.0.0.0/16"
* `private_ipv4_cidr_blocks` -- Optional. These are the cidr blocks to use for the private subnets, one for each AZ. 
  Defaults to ["10.0.128.0/21", "10.0.136.0/21", "10.0.144.0/21"] 
* `public_ipv4_cidr_blocks` -- Optional. These are the cidr blocks to use for the public subnets, one for each AZ.
  Defaults to ["10.0.0.0/21", "10.0.8.0/21", "10.0.16.0/21"]

*Outputs*
* `kms_account_key_arn` -- The [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) of the default 
  [KMS](https://aws.amazon.com/kms/) key (this is what handles encryption for redis, documentdb, eks, etc...)
* `kms_account_key_id` -- The [ID](https://docs.aws.amazon.com/kms/latest/developerguide/find-cmk-id-arn.html) of the default 
  KMS key (sometimes things need the ID, sometimes the ARN, so we're giving both)
* `vpc_id` -- The ID of the [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) we created for 
  this environment
* `private_subnet_ids` -- The IDs of the private [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) 
  we setup for your environment
* `public_subnets_ids` -- The IDs of the public [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) 
  we setup for your environment

## aws-dns
This module creates a [Route53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) for 
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but in order for this to actually receive traffic you will need to complete
the [dns setup](/docs/tutorials/ingress).

*Fields*
* domain -- Required. The domain you want (you will also get the subdomains for your use)
* delegated -- Optional. Set to true once the extra dns setup is complete.

*Outputs*
* zone_id -- The ID of the hosted zone created
* name_servers -- The name servers of your hosted zone (very important for the dns setup)
* domain -- The domain again
* cert_arn -- The arn of the [ACM certificate ](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) which
  is used for ssl.

## aws-eks
This module creates an [EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html), and a default
nodegroup to host your applications in. This needs to be added in the environment opta yml if you wish to deploy services
as opta services run on Kubernetes (just EKS for now).

*Fields*
* `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
* `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
* `node_disk_size` -- Optional. The size of disk to give the nodes' ec2s. Defaults to 20(GB)
* `node_instance_type` -- Optional. The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. Defaults
  to t3.medium (highly unrecommended to set to smaller)
* `k8s_version` -- Optional. The Kubernetes version for the cluster. Must be [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)

## k8s-base
This module is responsible for all the base infrastructure we package into the opta K8s environments. This includes:
* [Autoscaler](https://github.com/kubernetes/autoscaler) for scaling up and down the ec2s as needed
* [External DNS](https://github.com/kubernetes-sigs/external-dns) to automatically hook up the ingress to the hosted zone and its domain
* [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
* [Metrics server](https://github.com/kubernetes-sigs/metrics-server) for scaling different deployments based on cpu/memory usage
* [Linkerd](https://linkerd.io/) as our service mesh.

*Fields*
None for the user, we allow no configuration at the time.

*Outputs*
None

# GCP

## gcp-base
This module is the "base" module for creating an environment in gcp. It sets up the VPC, private subnet, default kms key 
and the db/cache subnets. Defaults are set to work 99% of the time, assuming no funny networking constraints (you'll know them
if you have them), so _no need to set any of the fields or no what the outputs do_.

## gcp-dns

## gcp-gke

# gcp-k8s-base
This module is responsible for all the base infrastructure we package into the opta K8s environments. This includes:
* [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
* [Linkerd](https://linkerd.io/) as our service mesh.

*Fields*
None for the user, we allow no configuration at the time.

*Outputs*
None

# Cloud agnostic

## datadog
This module setups the [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/?tab=helm) integration onto
the EKS cluster created for this environment. Please read the [datadog tutorial](/docs/tutorials/datadog) for all the
details of the features.

*Fields*
None. It'll prompt the use for a valid api key the first time it's run, but nothing else, and nothing in the yaml.

*Outputs*
None