---
title: "external-ssl-cert"
linkTitle: "external-ssl-cert"
date: 2021-07-21
draft: false
weight: 1
description: External SSL Certicate
---

This is the external ssl certificate module used to pass in pre-existing ssl cerificates to add to the opta
environment in the case dns delegation is not preferred. Please see the [ingress docs](/tutorials/ingress)
for more details.


## Fields

- `domain` - Required. The domain which the ssl cert is for (used for validation of the certificate files).
- `private_key_file` - Required. The private key pem file for the ssl certificate.
- `certificate_body_file` - Required. The body of the ssl certificate in the form of a pem file. This file should just have the final certificate and not other certificates on the chain
- `certificate_chain_file` - Required. The file containing the chain certificate for the current ssl certificate.

## Outputs

- domain - The domain passed in.