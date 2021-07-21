---
title: "aws-ses"
linkTitle: "aws-ses"
date: 2021-07-21
draft: false
weight: 1
description: Sets up AWS SES for sending domains via your root domain
---

### Fields

- `mail_from_prefix` -- Optional. Subdomain to use with root domain. `mail` by default.

### Outputs

None

### Notes

- It's required to set up the [`aws-dns`]({{< ref "/Modules/AWS/Environment/dns" >}} "aws-dns") module with this.
- Opta also files a ticket with AWS support to get out of SES sandbox mode.
