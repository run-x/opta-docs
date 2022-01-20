---
title: "Kubernetes Architecture"
linkTitle: "Kubernetes"
date: 2021-07-21
draft: false
weight: 1
description: >
  Architecture overview for Kubernetes clusters of Opta
---

<a href="/images/opta_internal_kubernetes_architecture.png" target="_blank">
  <img src="/images/opta_internal_kubernetes_architecture.png" align="center"/>
</a>

## Description

The K8s topology is divided into namespaces of 2 types: 3rd party integrations and Opta services. The third party
integrations consist of respected open source projects which handle background tasks or features expansions. These
currently consist of:

_Note_: GCP does an awesome job in support K8s and actually includes several of the following integrations/features by
default. Watch for the notes at the end of each description.

[Linkerd](https://linkerd.io/): Linkerd is the second most popular service mesh currently out there (right behind
Istio) and is the one we provide for our users. We chose it over Istio due to its absurdly simple maintenance and
upgrade stories while still offering the vast majority of the important service mesh features (e.g. traffic control,
grpc+http load balancing, mTLS, golden metrics). Linkerd also takes pride in its security and has undergone intense
security audits. The typical Opta user should not even see it.

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server): The official metric server, distributed separately
for EKS (comes with GKE) and used to power the standard horizontal pod autoscaler metrics (e.g. automatically scale up
or scale down your server as needed for current load). _Builtin on GKE and Azure_

[Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler): The official node
autoscaler, distributed separately for EKS (comes with GKE) and used to add/remove underlying machines (e.g. ec2s of
compute instances) serving as the nodes. _Builtin on GKE and Azure_

[Ingress Nginx](https://kubernetes.github.io/ingress-nginx/): An official ingress (i.e. how to expose the cluster to
the outside world) which uses a fleet of nginx containers to route incoming traffic from a load balancer to inside the
cluster and a desired service.

[External DNS](https://github.com/kubernetes-sigs/external-dns): An official project used to automatically add DNS
records for load balancers created by the cluster. _Not used on GKE or Azure_

[Datadog](https://github.com/DataDog/helm-charts/tree/master/charts/datadog): The official K8s integration for Datadog
which sends cluster metrics + events and container logs over to your datadog account. We also configure it to accept
any custom metrics or apm automatically by using their official client libraries. This integration is not part of the
opta K8s base, but most be added separately w/ the Datadog K8s module.

All of these additions (as well as the Opta services), are managed via [Helm Charts](https://helm.sh/) (using V3), and
are deployed separately to their own namespace.

Opta services are also deployed to unique namespaces formed out of their layer name (base name on the Opta yaml-- there
should never be more than one k8s service per Opta yaml). Each Opta service consists of one K8s service, deployment (and
its affiliated pods), horizontal pod autoscaler, configmap, service account, and optionally an ingress if they so wish
to expose their Opta service's api to the public. The deployment manages the different pods (e.g. containers/servers)
of your application while the K8s service is used with Linkerd to route cluster-internal traffic-- as is, any service
can be contacted via a domain of the form MODULE_NAME.LAYERNAME, such as app.hello-world for the Getting Started example. The horizontal pod
autoscaler is responsible for increasing/decreasing the number of pods of the deployment as needed based on cpu ad memory
usage. The service account ties the deployment to a given cloud IAM AWS role/GCP service account to get any permissions
for cloud resources (e.g. GCS/S3 access). There are no further K8s roles added to the service account meaning that
one Opta service will not be able to manipulate the K8s resources for another. The secret (always encrypted at rest) is
used for sensitive custom data, as well as database access credentials. Lastly, we have a configmap (for EKS) which
currently holds the latest public key needed for documentdb usage.

## Security Overview

- [Here is Linkerd's security audit](https://github.com/linkerd/linkerd2/blob/main/SECURITY_AUDIT.pdf)
- All cross-service communication is encrypted via mTLS
- All 3rd party charts used are the official ones when applicable or provided by bitnami and version-locked.
- All IAM roles for 3rd party charts are endowed with just the required permissions for their roles following the
  principle of least privilege.
- All Opta service deployments are bound to service accounts, with no extra K8s roles.
- Opta currently does not modify the aws-auth configmap for EKS.
- We use Helm V3
