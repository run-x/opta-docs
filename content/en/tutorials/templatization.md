---
title: "Templatization"
linkTitle: "Templatization"
date: 2021-07-21
draft: false
description: >
  How to templative parameters for multiple environments
---

Opta allows you to use the same service yml file with multiple environments.
Additionally, you can use variables to customize the behavior on a
per-environment basis.

```yaml
name: hello-world
environments:
  - name: staging
    path: "staging/opta.yml"
    variables:
      containers: 1
  - name: production
    path: "production/opta.yml"
    variables:
      containers: 5
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: ...
    healthcheck_path: ...
    public_uri: ...
    min_containers: 1
    max_containers: "{variables.containers}"
```

With this configuration, your service will have 5 max_containers in production
but only 1 in staging.
