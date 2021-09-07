---
title: "Environment Variables"
linkTitle: "Environment Variables"
date: 2021-07-21
draft: false
description: >
  How to pass in custom environment variables to your containers
---

Opta allows you to pass in custom environment variables to your k8s-service
([AWS](/modules-reference/service-modules/aws/#k8s-service) or [GCP](/modules-reference/service-modules/gcp/#k8s-service)).

Just use the `env_vars` field:

```yaml
name: hello-world
environments:
  - name: staging
    path: "staging/opta.yml"
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: ...
    healthcheck_path: ...
    public_uri: ...
    env_vars:
      API_KEY: "value"
```

With this configuration, your container will get an env var named `API_KEY` with
the value `value`!

You can also use Opta's interpolation features to refer to other values:

- "{layer_name}" refers to the current yml file's name
- "{parent_name}" refers to the parent file's name
- "{variables}" refers to [templatization variables](/miscellaneous/templatization)
- "{parent.output}" where `output` is the name of one of parent module's outputs
  (consult the module reference for output names)
