---
title: "external-ssl-cert"
linkTitle: "external-ssl-cert"
date: 2021-07-21
draft: false
weight: 1
description: External SSL Certicate
---

This is the external ssl certificate module used to pass in pre-existing ssl cerificates to add to the opta
environment in the case dns delegation is not preferred. Please see the [ingress docs](/miscellaneous/ingress) 
for more details.

## Fields

- `domain` -- Required. The domain which the ssl cert is for (used for validation of the certificate files).
- `private_key` -- Required. The private key pem file for the ssl certificate.
- `certificate_body` -- Required. The body of the ssl certificate in the form of a pem file. This file should just have 
   the final certificate and not other certificates on the chain
- `certificate_chain` -- Required. The file containing the chain certificate for the current ssl certificate.

## Outputs

- `private_key` -- The content of the private key file
- `certificate_body` -- The content of the certificate body file
- `certificate_chain` -- The content of the certificate chain file
- `domain` -- The domain passed in.