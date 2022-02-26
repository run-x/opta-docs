---
title: "external-ssl-cert"
linkTitle: "external-ssl-cert"
date: 2021-07-21
draft: false
weight: 1
description: External SSL Certicate
---

This is the external ssl certificate module used to pass in pre-existing ssl cerificates to add to the opta
environment in the case dns delegation is not preferred. Please see the [ingress docs](/features/ingress)
for more details.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `domain` | The domain which the ssl cert is for (used for validation of the certificate files). | `default_value` | True |
| `private_key_file` | The private key pem file for the ssl certificate. | `None` | True |
| `certificate_body_file` | The body of the ssl certificate in the form of a pem file. This file should just have the final certificate and not other certificates on the chain | `None` | True |
| `certificate_chain_file` | The file containing the chain certificate for the current ssl certificate. | `None` | True |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `domain` | The domain passed in. |