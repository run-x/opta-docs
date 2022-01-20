---
title: "GCP Architecture"
linkTitle: "GCP"
date: 2021-07-21
draft: false
weight: 1
description: >
  Architecture overview for GCP deployments of Opta
---

<a href="/images/opta_gcp_architecture.png" target="_blank">
  <img src="/images/opta_gcp_architecture.png" align="center"/>
</a>

## Description

For GCP our environments are currently setup within a single region/subnet which google can automatically distribute
between all the region's availability zones. The subnet is a private one and only the load balancer and GCS buckets
are allowed to be reachable from the public internet (although the GCS buckets would typically require credentials).
In order to keep networking as private as possible, we setup a
[service networking peering](https://cloud.google.com/vpc/docs/private-service-connect) so that the databases and caches
can be accessed via private connection and so have no public endpoints.

We deploy the GKE cluster with one nodegroup spanning all the azs in the region/subnet. By default, it is subrscribed to
the "REGULAR" [channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels), but that can be
manually overridden if needed. Currently, there is a public cluster endpoint, but this may be revisited once a story
for VPN support is planned out.
[Encryption for the secrets is also provided via KMS](https://cloud.google.com/kubernetes-engine/docs/how-to/encrypting-secrets).

For databases, we currently have modules for postgres, mysql, and redis. We only offer 1 instance per db
(no read or write replicas), but we hope to add this feature as customers demand. The postgres and mysql databases are
built with 7 day retention of backups in case of emergency. The username and passwords are created with the database
and are passed securely to the K8s services as secrets (pls see K8s section for security around secrets).

There is a module for GCS storage, which creates a private bucket by default (but can be set to public via fields)
and all the buckets are encrypted at rest with the environment's base kms key.

Lastly, DNS and SSL are currently handled via one Cloud DNS hosted zone and one Google-managed ssl certificate
respectively. SSL cert verification is done automatically by GCP by manipulating existing resources. Records will be
added to the hosted zone directing to the load balancer via an open source integration (see K8s section).

## Security Overview

- With linkerd and domain delegation complete, Opta environments will have end-to-end encryption on all Opta services.
- All vms are run within the private subnet (i.e. can access the internet via a nat gateway, but
  nothing external can reach them).
- All databases/caches are run with the service connect option (peering with GCP's internal networks) and are not publicly exposed.
- Databases and caches are currently encrypted using
  [GCP's managed keys](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa).
  Opta will switch to encrypt via customer managed keys once such features are GA.
- All database connections use SSL encryption.
- Redis connections do NOT ssl encryption at the moment due to
  [the difficulty of configuration](https://cloud.google.com/memorystore/docs/redis/in-transit-encryption). We will
  re-address this issue based on customer demand.
- All GCS buckets are encrypted with the environment's default KMS key.
- All networking access is managed via firewall rules either auto-provisioned by GKE, or manually crafted (currently
  opening up full connection within the private network).
- The GKE node vms are created with a service account using the [recommended least privilege list](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa)
- No long-lived IAM credentials are ever created.
- All GCR images/repos are private to the account.
- GCS buckets created privately by default.
- 7 day backup retentions for the postgres/mysql databases.
- Currently, the GKE cluster is built with a public endpoint for the simple usage (can add private option later on once
  VPN feature is added).
