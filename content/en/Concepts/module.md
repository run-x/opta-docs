---
title: "Module"
linkTitle: "Module"
draft: false
weight: 3
description: >
  A high-level building block to provision some infrastructure.
---

## What is a Module?

Opta gives you a vast library of modules that you can connect together to build your ideal Infrastructure stack.

A module is a high-level construct that provision the infrastructure related to achieve the module goal.

## Definition

A module has the following properties:
- the type of the module
- an optional name (useful if you want to have many modules of the same type)
- some optional configuration for the module

A module is defined inside a environment or layer file in the `modules` section.

Example: MySQL database module:
```yaml
modules:
  - type: mysql
```

## Minimal configuration

We built Opta with the idea that you should be able to install a new infrastructure resource by just writing a single line.

Example: create a Kubernetes cluster and a Postgres Database.
```yaml
modules:
  - type: k8s-cluster
  - type: postgres
```

When not setting any extra attribute, Opta will use the default configuration.
By default, Opta follows infrastucture best practices, so you don't need to get lost in low level cloud configuration.

Of course, if you have some special requirements, every module provides an api to allow you to configure according to your needs.

Example: the same modules with extra configuration
```yaml
modules:
  - name: devcluster
    type: k8s-cluster
    node_instance_type: t3.medium
    max_nodes: 5
    spot_instances: true
  - name: dbfrontend
    type: postgres
    instance_class: db.t3.medium
    engine_version: "12.4"
```

Contrary to other tools, you only need to specify the values that you want to customize.
For everything else, Opta will use the recommended values.

## Links

Another key feature is that the modules can be linked, so a module can use the output of another one.

Example: a helm chart module uses the auth token for a redis store created by another module.
```yaml

  - name: redis
    type: redis
  - type: helm-chart
    repository: https://airflow.apache.org
    chart: airflow
    namespace: airflow
    chart_version: 1.4.0
    values:
      data:
        brokerUrl: "rediss://:${{module.redis.cache_auth_token}}@${{module.redis.cache_host}}"
```

## Terraform compatible

Opta uses Terraform under the hood - so you're never locked in. 
You can always write custom Terraform or even take the Opta generated Terraform and go your own way!

## Next steps

- Learn about [Layer](/concepts/layer/).
- Explore the api for all modules: [Reference](/reference/)
