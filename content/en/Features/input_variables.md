---
title: "Input Variables"
linkTitle: "Input Variables"
date: 2022-01-27
description: Passing Input Variables to Opta
---

Opta supports passing input variables at runtime to be used when generating the underlying terraform
specifications. This is done by first specifying which input variables to accept within the manifest via the
optional `input_variables` field like so:

```yaml
# opta.yaml
name: staging # name of the environment
org_name: my-org # A unique identifier for your organization
providers:
  aws:
    region: us-east-1
    account_id: XXXX # Your 12 digit AWS account id
input_variables:
  - name: min_nodes
    default: "2"
  - name: max_nodes
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
    min_nodes: "{vars.min_nodes}"
    max_nodes: "{vars.max_nodes}"
```

Each `input_variables` must have a name and can optionally have a `default` value to use if no override is
specified. If an entry does not have a default field (like max_nodes in our example), then it will be required to 
be inputted at runtime.

The values are then passed at runtime using repeatable passes of the `--var` flag like so:

`opta apply -c staging.yaml --var min_nodes=3 --var max_nodes=5`
