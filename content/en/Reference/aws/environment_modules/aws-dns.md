---
title: "dns"
linkTitle: "dns"
date: 2021-07-21
draft: false
weight: 1
description: Adds dns to your environment
---

This module creates a [Route53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) for
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but in order for this to actually receive traffic you will need to complete
the [dns setup](/tutorials/ingress).


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `domain` | The domain you want (you will also get the subdomains for your use) | `None` | True |
| `delegated` | Set to true once the extra [dns setup is complete](/tutorials/ingress) and it will add the ssl certs. | `False` | False |
| `upload_cert` | Deprecated | `False` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `zone_id` | The ID of the hosted zone created |
| `name_servers` | The name servers of your hosted zone (very important for the dns setup) |
| `domain` | The domain again |
| `cert_arn` | The arn of the ACM certificate which is used for ssl. |