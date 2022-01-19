---
title: "Secrets"
linkTitle: "Secrets"
date: 2022-01-19
description: >
  Creating secrets for your application
---

Opta provides built-in secret management for your applications. Any secrets like database passwords, api keys, should not be written in the code (including opta.yaml) because if the code is leaked accidentally, your infrastructure is exposed to hackers.

Opta enables you to store these in an encrypted fashion inside the kubernetes
cluster. To use the secrets functionality use the `opta secret` command.

For this example, we can reuse the service defined in the [Getting Started](/getting-started/) guide.

```yaml
# hello.yaml
name: hello
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - type: k8s-service
    name: hello
    port:
      http: 80
    image: ghcr.io/run-x/opta-examples/hello-app:main
    healthcheck_path: "/"
    public_uri: "/hello"

```


1. Create or update a secret with the `secret update` command

    ```bash
    opta secret update -c hello.yaml MY_SECRET_1 "value_1"
    ```
    ```
    Success
    ```

1. Or if you want to create multiple secrets, use the `secret bulk-update` command

    ```
    # example of .env file containing secrets
    cat secrets.env 
    MY_SECRET_2=value_2
    MY_SECRET_3=value_3
    ```
    ```bash
    opta secret bulk-update -c hello.yaml secrets.env
    ```
    ```
    Success
    ```

1. List all secrets with the `secret list` command

    ```bash
    opta secret list -c hello.yaml
    ```
    ```console
    MY_SECRET_1=value_1
    MY_SECRET_2=value_2
    MY_SECRET_3=value_3
    ```

1. View a secret value with the `secret view` command

    ```bash
    opta secret view -c hello.yaml MY_SECRET_1
    ```
    ```
    value_1
    ```

2. If you the service to access the secrets at runtime, add them to the service opta file.

    ```yaml
    name: hello
    environments:
      - name: staging
        path: "opta.yaml"
    modules:
      - type: k8s-service
        name: hello
        port:
          http: 80
        image: ghcr.io/run-x/opta-examples/hello-app:main
        # add this section below
        secrets:
          - MY_SECRET_1
          - MY_SECRET_2
          - MY_SECRET_3
    ```

    ```bash
    # apply the changes to have the secrets defined as environment variables
    opta apply -c hello.yaml
    ```

    ```bash
    # test that the secrets are available at runtime
    opta shell -c hello.yaml
    env | grep MY_SECRET_
    MY_SECRET_1=value_1
    MY_SECRET_2=value_2
    MY_SECRET_3=value_3
    ```
