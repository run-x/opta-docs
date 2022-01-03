---
title: "Environment Variables"
linkTitle: "Environment Variables"
date: 2022-01-03
draft: false
description: >
  How to pass in custom environment variables to your containers
---

Opta allows you to pass in custom environment variables to your k8s-service
([AWS](/reference/service-modules/aws/#k8s-service) or [GCP](/reference/service-modules/gcp/#k8s-service)).

Just use the `env_vars` field:

{{< highlight yaml "hl_lines=13-15" >}}
name: hello
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - name: hello
    type: k8s-service
    port:
      http: 80
    image: ghcr.io/run-x/opta-examples/hello-app:main
    healthcheck_path: "/"
    public_uri: "/hello"
    env_vars:
      - name: "API_KEY"
        value: "value"
{{< / highlight >}}

With this configuration, your container will get an env var named `API_KEY` with
the value `value`!

You can also use Opta's interpolation features to refer to other values:

- "{variables}" refers to [templatization variables](/tutorials/templatization_variables)
- "{parent.output}" where `output` is the name of one of parent module's outputs
  (consult the module reference for output names)
