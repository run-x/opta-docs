---
title: "Templatization Variables"
linkTitle: "Templatization Variables"
date: 2022-01-03
draft: false
description: >
  How to templative parameters for multiple environments
---

Opta allows you to use the same service yml file with multiple environments.
Additionally, you can use variables to customize the behavior on a
per-environment basis.

{{< highlight yaml "hl_lines=5-6 9-10 20" >}}
name: hello
environments:
  - name: staging
    path: "staging/opta.yaml"
    variables:
      containers: 1
  - name: staging
    path: "production/opta.yaml"
    variables:
      containers: 5
modules:
  - name: hello
    type: k8s-service
    port:
      http: 80
    image: ghcr.io/run-x/opta-examples/hello-app:main
    healthcheck_path: "/"
    public_uri: "/hello"
    min_containers: 1
    max_containers: "{variables.containers}"
{{< / highlight >}}

With this configuration, your service will have 5 max_containers in production
but only 1 in staging.
