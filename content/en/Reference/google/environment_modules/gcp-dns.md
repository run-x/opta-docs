---
title: "dns"
linkTitle: "dns"
date: 2021-07-21
draft: false
weight: 1
description: Adds dns to your environment
---

This module creates a GCP [managed zone](https://cloud.google.com/dns/docs/zones) for
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but in order for this to actually receive traffic you will need to complete
the [dns setup](/tutorials/ingress).


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `domain` | The domain you want (you will also get the subdomains for your use) | `None` | True |
| `delegated` | The  Set to true once the extra [dns setup is complete](/tutorials/ingress) and it will add the ssl certs. | `False` | False |
| `subdomains` | A list of subdomains to also get ssl certs for. | `[]` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `zone_id` | The ID of the hosted zone created |
| `zone_name` | The name of the hosted zone created |
| `name_servers` | The name servers of your hosted zone (very important for the dns setup) |
| `domain` | The domain again |
| `delegated` | Passing the delegated field forward |
| `cert_self_link` | Self link to the certificate if delegated |