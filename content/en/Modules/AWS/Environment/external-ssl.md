---
title: "external-ssl"
linkTitle: "external-ssl"
date: 2021-07-28
draft: false
weight: 1
description: Allows user to pass in their own ssl certificate to use from their local filesystem (using a relative path from the opta yaml)
---

This module does not create any real resources but acts as a way to integrate a user's pre-existing ssl certificate into the
opta system. This is useful if the user does not wish to / cannot do the dns delegation steps for ssl and wants to
handle creating the ssl certificate and adding the appropriate dns cnames themselves.

### Fields

- `domain` -- Required. The domain for your cert (used for verification). Don't worry if the cert also supports wildcared subdomains.
- `private_key_file` -- Required. The relative path to the pem private key file for your cert. Is of the form `-----BEGIN PRIVATE KEY-----...-----END PRIVATE KEY-----`
- `certificate_body_file` -- Required. The relative path to the certicate body file. This is sometimes called "cert.pem" and is a file 
  consisting of a single `-----BEGIN CERTIFICATE-----...-----END CERTIFICATE-----` block. If you only have one big pem file with
  many such blocks, then create a new file and add **just** the first block.
- `certificate_chain_file` -- Required. The relative path to the certicate chain file. This is sometimes called "chain.pem" and is a file
  consisting of one or (usually) more `-----BEGIN CERTIFICATE-----...-----END CERTIFICATE-----` blocks. If you only have one big pem file with
  many such blocks, then create a new file and add all the blocks **except** the first one.

### Outputs

- `domain` -- The domain again