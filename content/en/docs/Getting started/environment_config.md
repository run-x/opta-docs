---
title: "Environment configuration"
linkTitle: "Environment configuration"
date: 2020-02-01
description: >
  Configuration details for the environment yaml
---

```yaml
meta:
  name: staging  # name of the environment
  org_id: runx # unique org id
  providers:
    aws:
      region: us-east-1  # AWS region where you want to deploy your apps
      allowed_account_ids: [ 889760294590 ]  # replace this with your AWS account id
  variables:
    domain: "staging.example.com"  # replace this with a domain you own
    datadog_api_key: ""

_init: {}
```

TODO:
* Specify the nodegroup size, min, max
* Link of instructions to setup domain
