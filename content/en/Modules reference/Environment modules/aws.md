---
title: "AWS environment modules"
linkTitle: "AWS"
date: 2020-02-01
draft: false
weight: 1
description:
---

## base
This module is the "base" module for creating an environment in aws. It sets up the VPCs, default kms key and the
db/cache subnets. Defaults are set to work 99% of the time, assuming no funny networking constraints (you'll know them
if you have them), so _no need to set any of the fields or know what the outputs do_.

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

## dns
This module creates a [Route53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) for 
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but in order for this to actually receive traffic you will need to complete
the [dns setup](/miscellaneous/ingress).

*Fields*
* domain -- Required. The domain you want (you will also get the subdomains for your use)
* delegated -- Optional. Set to true once the extra dns setup is complete.

*Outputs*
* zone_id -- The ID of the hosted zone created
* name_servers -- The name servers of your hosted zone (very important for the dns setup)
* domain -- The domain again
* cert_arn -- The arn of the [ACM certificate ](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) which
  is used for ssl.

## k8s-cluster
This module creates an [EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html), and a default
nodegroup to host your applications in. This needs to be added in the environment opta yml if you wish to deploy services
as opta services run on Kubernetes.

*Fields*
* `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
* `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
* `node_disk_size` -- Optional. The size of disk to give the nodes' ec2s. Defaults to 20(GB)
* `node_instance_type` -- Optional. The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. Defaults
  to t3.medium (highly unrecommended to set to smaller)
* `k8s_version` -- Optional. The Kubernetes version for the cluster. Must be [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
* `spot_instances` -- Optional. A boolean specifying whether to use [spot instances](https://aws.amazon.com/ec2/spot/) 
  for the default nodegroup or not. The spot instances will be configured to have the max price equal to the on-demand
  price (so no danger of overcharging). *WARNING*: By using spot instances you must accept the real risk of frequent abrupt
  node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small
  risk as containers of opta services will be automatically restarted on surviving nodes. So just make sure to specify
  a minimum of more than 1 containers -- opta by default attempts to spread them out amongst many nodes. The former
  is a graver concern which can be addressed by having multiple node groups of different instance types (see aws 
  nodegroup module) and ideally at least one non-spot. Default false

## aws-nodegroup
Create an additional nodegroup for the primary EKS cluster. Note that the
`aws-eks` module creates a default nodegroup so this should only be used when
you want one more.

*Fields*
* `max_nodes` -- Optional. Default = 15
* `min_nodes` -- Optional. Default = 3
* `node_disk_size` -- Optional. Default = 20
* `node_instance_type` -- Optional. Default = t3.medium
* `uge_gpu` -- Optional. Default = false
* `spot_instances` -- Optional. Default = false

*Outputs*
None

## k8s-base
This module is responsible for all the base infrastructure we package into the opta K8s environments. This includes:
* [Autoscaler](https://github.com/kubernetes/autoscaler) for scaling up and down the ec2s as needed
* [External DNS](https://github.com/kubernetes-sigs/external-dns) to automatically hook up the ingress to the hosted zone and its domain
* [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
* [Metrics server](https://github.com/kubernetes-sigs/metrics-server) for scaling different deployments based on cpu/memory usage
* [Linkerd](https://linkerd.io/) as our service mesh.

*Fields*
* `nginx_high_availability` -- Optional. Deploy the nginx ingress in a high-availability configuration. Default = false
* `linkerd_high_availability` -- Optional. Deploy the linkerd service mesh in a high-availability configuration for its control plane. Default = false
* `linkerd_enabled` -- Optional. Enable the linkerd service mesh installation. Default =  true

*Outputs*
None

## aws-ses

Sets up AWS SES for sending domains via your root domain. Note:
- It's required to set up the aws-dns module with this.
- Opta also files a ticket with AWS support to get out of SES sandbox mode.

*Fields*
* `mail_from_prefix` -- Optional. Subdomain to use with root domain. `mail` by default.

*Outputs*
None
