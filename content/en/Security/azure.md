---
title: "Azure Architecture"
linkTitle: "Azure"
date: 2021-07-21
draft: false
weight: 1
description: >
  Architecture overview for Azure deployments of Opta
---

<a href="/images/opta_azure_architecture.png" target="_blank">
  <img src="/images/opta_azure_architecture.png" align="center"/>
</a>

## Description

For Azure, our environments are currently setup within a single region/subnet which azure can automatically distribute
between all the region's availability zones. The subnet is a private one and only the load balancer and Azure storage
are allowed to be reachable from the public internet (although the Azure storage would typically require credentials).
In order to keep networking as private as possible, we setup a
[private endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview) so that the 
databases and caches can be accessed via private connection and so have no public endpoints.

We deploy the AKS cluster with one node pool spanning all the azs in the region/subnet. By default, it is set to version 
1.19.11 but that can be manually overridden if needed. 
Currently, there is a public cluster endpoint, but this may be revisited once a story for VPN support is planned out.

For databases, we currently have modules for postgres, and redis. We only offer 1 instance per db
(azure handles geo-redundant backups), but we hope to add this feature as customers demand. The postgres databases are
built with 7 day retention of backups in case of emergency. The username and passwords are created with the database
and are passed securely to the K8s services as secrets (pls see K8s section for security around secrets).

There currently is no module for for a user to provision their own storage account/container, but that will come in due
time.

Lastly, Opta does not handle DNS or SSL in Azure due to complexities of Azure. Opta does provide ways of adding your
[own ssl certificate into our system](/miscellaneous/ingress) to get SSL. Once your DNS zone points to the IP address of the load balancer
provisioned by Opta your application will be live and protected by SSL.

## Security Overview

- With linkerd and domain delegation complete, Opta environments will have end-to-end encryption on all Opta services.
- All vms are run within the private subnet (i.e. can access the internet via a nat gateway, but
  nothing external can reach them).
- All databases/caches are run with the private endpoint option and are not publicly exposed.
- All database/redis connections use SSL encryption.
- No long-lived IAM credentials are ever created.
- All ACR images/repos are private to the account.
- Azure storage accounts/containers will be created privately by default.
- 7 day backup retentions for the postgres/mysql databases.
- Currently, the AKS cluster is built with a public endpoint for the simple usage (can add private option later on once
  VPN feature is added).