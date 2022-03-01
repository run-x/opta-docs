---
title: "Environment"
linkTitle: "Environment"
draft: false
weight: 2
description: >
  The common frame that powers your infrastructure.
---

## What is an Environment?

Environment files specify which cloud, account, and region to configure
infrastructure in. From this file, Opta will create all the
base resources, including: kubernetes clusters, networks, IAM roles, ingress,
service mesh, etc. Usually, you'll have one environment file for staging, one
for production, one for quality assurance (QA), etc.

You can also create one environment per engineer or pull request, which gives
each member of your team an isolated development sandbox.


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