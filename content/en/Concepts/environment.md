---
title: "Environment"
linkTitle: "Environment"
draft: false
weight: 2
description: >
  The common frame that powers your infrastructure.
---

## What is an Environment?

An Environment is the common frame that powers your infrastructure.

An environment has the following properties:
- an unique name
- the cloud provider connection information
- a list of modules to be installed


## Definition

An environment is defined in a yaml file.

```yaml
# Name of the environment
name: awsenv-ci
org_name: runx
providers:
  # example for AWS
  aws:
    region: us-east-1
    account_id: XXXX # Your 12 digit AWS account id
modules:
  # creates the network
  - type: base
  # additional modules, ex: k8s-cluster
```

## Next steps

- Learn about [modules](/concepts/module/).