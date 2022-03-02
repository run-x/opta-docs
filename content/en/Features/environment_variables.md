---
title: "Environment Variables"
linkTitle: "Environment Variables"
date: 2022-01-03
draft: false
description: >
  How to pass in custom environment variables to your containers
---


### Set custom environment variables

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
    image: ghcr.io/run-x/hello-opta/hello-opta:main
    healthcheck_path: "/"
    public_uri: "/hello"
    env_vars:
      - name: "API_KEY"
        value: "value"
{{< / highlight >}}

With this configuration, your container will get an env var named `API_KEY` with
the value `value`!

You can also use Opta's interpolation features to refer to other values:

- "{variables}" refers to [templatization variables](/features/environment_variables/#specify-the-environment-to-use)
- "{parent.output}" where `output` is the name of one of parent module's outputs
  (consult the module reference for output names)

### Specify the environment to use

Opta allows you to use the same service yml file with multiple environments.
Additionally, you can use variables to customize the behavior on a
per-environment basis.

{{< highlight yaml "hl_lines=5-6 9-10 20" >}}
# hello.yaml
name: hello
environments:
  - name: staging
    path: "staging/opta.yaml"
    variables:
      containers: 1
  - name: production
    path: "production/opta.yaml"
    variables:
      containers: 5
modules:
  - name: hello
    type: k8s-service
    port:
      http: 80
    image: ghcr.io/run-x/hello-opta/hello-opta:main
    healthcheck_path: "/"
    public_uri: "/hello"
    min_containers: 1
    max_containers: "{variables.containers}"
{{< / highlight >}}

With this configuration, your service will have 5 max_containers in production
but only 1 in staging.

To specify the environment to use use the `--env` flag:
```bash
opta apply -c hello.yaml --env staging
```
