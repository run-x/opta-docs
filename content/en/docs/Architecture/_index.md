---
title: "Architecture"
linkTitle: "Architecture"
weight: 6
description: >
  An overview of the Architecture Opta sets up. 
---

The core principle of Opta is to not have our users compromise between cost, UX and implementation. To that end, Opta
sets up a sophisticated, yet robust, architecture for your services and environments behind the scenes. This 
architecture can be broken up between resources in the base cloud provider (e.g. AWS, GCP), and internal to the 
kubernetes clusters we deploy. Below are the specifications and answers for the common security questions.

## AWS
![image alt text](/images/opta_aws_architecture.png)
For AWS our environments are currently setup within a single region, but our networking is set up across 3 availability
zones by default, split between a private and public subnet (which we provision as we do not use the default vpc). 
The public subnet is solely used for the public load balancer, while the ec2s (VMs) and databases all exist within
the private subnet.

We deploy the EKS cluster with one nodegroup spanning all the private subnets created. The current EKS cluster version
is 1.18, but this can be manually overridden if needed (and we get security patches as needed automatically via EKS).
Currently, there is a public cluster endpoint, but this may be revisited once a story for VPN support is planned out.
[Encryption for the secrets is also provided via KMS](https://aws.amazon.com/blogs/containers/using-eks-encryption-provider-support-for-defense-in-depth/).

For databases, we currently have modules for postgres (AWS Aurora), redis (AWS Elasticache), and the mongodb compatible
documentdb (AWS Documentdb). We only offer 1 instance per db (no read or write replicas), but we hope to add this
feature as customers demand. The postgres and documentdb databases are built with 5 day retention of backups in case of
emergency. The username and passwords are created with the database and are passed securely to the K8s services as 
secrets (pls see K8s section for security around secrets).

There also is a module for S3 storage, which creates a private bucket by default (but can be set to public via fields)
and all the buckets are encrypted at rest with AES 256 regardless.

Lastly, DNS and SSL are currently handled via one Route53 hosted zone and one ACM certificate respectively. ACM cert
verification is done with Route53 record manipulation in the given hosted zone. Records will be added to the hosted
zone directing to the load balancer via an open source integration (see K8s section).

### Security Concerns
* All databases and ec2s are run within the private subnets (i.e. can access the internet via a nat gateway, but 
  nothing external can reach them).
* All databases (redis, documentdb, sql) are encrypted at rest with a KMS key provisioned by the environment.
* All database connections use SSL encryption.
* All S3 buckets are encrypted with AES 256.
* All networking access is managed via security groups either auto-provisioned by EKS, or manually crafted to just 
  expose to the VPC and just the ports required for standard usage (i.e. 5432 for postgres).
* The EKS node ec2s are created with just the AmazonEKSClusterPolicy
* The EKS storage (e.g. K8s secrets) is encrypted at rest via KMS 
* K8s service accounts are mapped to IAM roles via the officially sanctioned [OIDC](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
  manner, with no long-lived credentials.
* No long-lived IAM credentials are ever created.
* All ECR images/repos are private to the account.
* S3 buckets created privately by default.  
* 5 day backup retentions for the postgres/documentdb databases.  
* Currently, the EKS cluster is built with a public endpoint for the simple usage (can add private option later on once
  VPN feature is added).

## GCP
_Coming soon!_

## K8s
![image alt text](/images/opta_internal_kubernetes_architecture.png)

The K8s topology is divided into namespaces of 2 types: 3rd party integrations and opta services. The third party 
integrations consist of respected open source projects which handle background tasks or features expansions. These
currently consist of:

_Note_: GCP does an awesome job in support K8s and actually includes several of the following integrations/features by
default. Watch for the notes at the end of each description.

[Linkerd](https://linkerd.io/): Linkerd is the second most popular service mesh currently out there (right behind 
Istio) and is the one we provide for our users. We chose it over Istio due to its absurdly simple maintenance and 
upgrade stories while still offering the vast majority of the important service mesh features (e.g. traffic control,
grpc+http load balancing, mTLS, golden metrics). Linkerd also takes pride in its security and has undergone intense
security audits. The typical opta user should not even see it.

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server): The official metric server, distributed separately
for EKS (comes with GKE) and used to power the standard horizontal pod autoscaler metrics (e.g. automatically scale up
or scale down your server as needed for current load). _Builtin on GKE_

[Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler): The official node 
autoscaler, distributed separately for EKS (comes with GKE) and used to add/remove underlying machines (e.g. ec2s of 
compute instances) serving as the nodes. _Builtin on GKE_

[Ingress Nginx](https://kubernetes.github.io/ingress-nginx/): An official ingress (i.e. how to expose the cluster to 
the outside world) which uses a fleet of nginx containers to route incoming traffic from a load balancer to inside the
cluster and a desired service. _Not used on GKE_

[External DNS](https://github.com/kubernetes-sigs/external-dns): An official project used to automatically add DNS 
records for load balancers created by the cluster.

[Datadog](https://github.com/DataDog/helm-charts/tree/master/charts/datadog): The official K8s integration for Datadog
which sends cluster metrics + events and container logs over to your datadog account. We also configure it to accept
any custom metrics or apm automatically by using their official client libraries. This integration is not part of the
opta K8s base, but most be added separately w/ the Datadog K8s module.

All of these additions (as well as the Opta services), are managed via [Helm Charts](https://helm.sh/) (using V3), and
are deployed separately to their own namespace.

Opta services are also deployed to unique namespaces formed out of their layer name (base name on the opta yaml-- there
should never be more than one k8s service per opta yaml). Each opta service consists of one K8s service, deployment (and
its affiliated pods), horizontal pod autoscaler, configmap, service account, and optionally an ingress if they so wish
to expose their opta service's api to the public. The deployment manages the different pods (e.g. containers/servers)
of your application while the K8s service is used with Linkerd to route cluster-internal traffic-- as is, any service 
can be contacted via a domain of the form MODULE_NAME.LAYERNAME, such as app.hello-world for the Getting Started example. The horizontal pod
autoscaler is responsible for increasing/decreasing the number of pods of the deployment as needed based on cpu ad memory 
usage. The service account ties the deployment to a given cloud IAM AWS role/GCP service account to get any permissions
for cloud resources (e.g. GCS/S3 access). There are no further K8s roles added to the service account meaning that
one Opta service will not be able to manipulate the K8s resources for another. The secret (always encrypted at rest) is 
used for sensitive custom data, as well as database access credentials. Lastly, we have a configmap (for EKS) which 
currently holds the latest public key needed for documentdb usage.

### Security Concerns
* [Here is Linkerd's security audit](https://github.com/linkerd/linkerd2/blob/main/SECURITY_AUDIT.pdf)
* All cross-service communication is encrypted via mTLS
* All 3rd party charts used are the official ones when applicable or provided by bitnami and version-locked.
* All IAM roles for 3rd party charts are endowed with just the required permissions for their roles following the
  principle of least privilege.  
* All opta service deployments are bound to service accounts, with no extra K8s roles.
* Opta currently does not modify the aws-auth configmap for EKS.
* We use Helm V3
