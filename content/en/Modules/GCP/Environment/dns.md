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
the [dns setup](/miscellaneous/ingress).

## Fields

- domain -- Required. The domain you want (you will also get the subdomains for your use)
- delegated -- Optional. Set to true once the extra dns setup is complete and it will add the ssl certs.
- subdomains -- Optional. A list of subdomains to also get ssl certs for.

## Outputs

- zone_id -- The ID of the hosted zone created
- name_servers -- The name servers of your hosted zone (very important for the dns setup)
- domain -- The domain again
- cert_arn -- The arn of the [ACM certificate ](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) which
  is used for ssl.
