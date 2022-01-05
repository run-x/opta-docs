---
title: "Secrets"
linkTitle: "Secrets"
date: 2022-01-03
description: >
  Creating secrets for your application
---

Opta provides built-in secret management for your applications. Any secrets like database passwords, api keys, should not be written in the code (including opta.yaml) because if the code is leaked accidentally, your infrastructure is exposed to hackers.

Opta enables you to store these in an encrypted fashion inside the kubernetes
cluster. To use the secrets functionality:

- Define the secrets in the service's opta file
- Use the `opta secret` cli to update the values
- With the next `opta deploy`, these secrets will be visible to your container
  as environment variables.

1. Define secrets in the service file:

{{< highlight yaml "hl_lines=11-13" >}}
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
    secrets:
      - MY_SECRET_1
      - MY_SECRET_2
{{< / highlight >}}



2. Update a secret

```bash
opta secret update MY_SECRET_1 "value"

Success
```

3. List all secrets

```bash
opta secret list

MY_SECRET_1
MY_SECRET_2
```

4. View a secret value

```bash
opta secret view MY_SECRET_1

value
```
