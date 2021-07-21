---
title: "dns"
linkTitle: "dns"
date: 2021-07-21
draft: false
weight: 1
description: Creates a dns zone for your given domain
---

This module creates an Azure [dns zone](https://azure.microsoft.com/en-us/services/dns/) for
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but SSL support is still incoming.

### Fields

- `domain` -- Required. The domain you want (you will also get the subdomains for your use)

### Outputs

- `zone_id` -- The ID of the hosted zone created
- `name_servers` -- The name servers of your hosted zone (very important for the dns setup)
- `domain` -- The domain again
