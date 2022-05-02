---
title: "Variables"
linkTitle: "Variables"
date: 2021-07-21
description: How Opta handles variables
---

When writing an Opta file, users will often wish to have variables which can be changed/inputted based on different
conditions/settings. Opta does support this minimal templating via a series of variables that can be used and inserted
in a variety of ways. They are as follows:

## Input Variables
Opta supports passing input variables at runtime to be used when generating the underlying terraform
specifications. This allows you to make your Opta template file reusable. This is done by first specifying which input
variables to accept within the manifest via the optional `input_variables` field like so:

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

## Environment Variables
Opta allows you to use the same service yaml file with multiple environments.
Additionally, you can use variables to customize the behavior on a
per-environment basis.

```yaml
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
```

With this configuration, your service will have 5 max_containers in production
but only 1 in staging.

To specify the environment to use use the `--env` flag:
```bash
opta apply -c hello.yaml --env staging
```

## Parent Output Variables
Opta allows you to refer to `outputs` of the "parent" environment yaml as variables in their subsidiary services. These
variables are denoted in the form of `{parent.output}`. For example, take for instance this http-service yaml which
(assuming that the environment has a dns module) sets the `public_uri` to accept traffic of the `domain` output of the
environment yaml:

```yaml
name: http-service
environments:
  - name: production
    path: "./production.yaml"
modules:
  - name: app
    type: k8s-service
    image: kennethreitz/httpbin
    healthcheck_path: "/get"
    port:
      http: "80"
    public_uri: "{parent.domain}/hello"
```

To view the full list of variables available to you, simply run the `opta output` command on your environment yaml.
