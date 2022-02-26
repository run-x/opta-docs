---
title: "Layer"
linkTitle: "Layer"
draft: false
weight: 4
description: >
  A independently managed set of modules.
---

## What is a Layer?

You can add all your modules to an environment file, but if you want more granularity you can define some layers.

A layer provision some modules together as a single unit.

A layer has the following properties:
- an unique name
- the environment(s) to use with the layer 
- a list of modules


## Definition

A layer is defined in a yaml file.

Example a layer for a kubernetes service with a database.
```yaml
name: mernbackend
environments:
  - name: awsenv
    path: "../awsenv.yaml"
modules:
  - name: mernbackend
    type: k8s-service
    public_uri: "/mernbackend"
    links:
      - mongodb:
         -  mongodb_atlas_connection_string: MONGODB_URI
            db_user: MONGODB_USER
            db_password: MONGODB_PASSWORD
  - name: mongodb
    type: mongodb-atlas
```

## When to use layers?

The most common use cases are:
- You would like to break down a large environment file into separate layers, so they can be maintained separately.
- You have more than one environment and would like to avoid repeating the same modules in each environment file.

<figure>
<img src="/images/service_environment_files_linking.png" alt="Service and environment files link" style="width:100%">
<figcaption align = "center"><b>service_a.yaml is a layer file defining a kubernetes service</b></figcaption>
</figure>