---
title: "Secrets"
linkTitle: "Secrets"
date: 2020-02-01
description: >
  Creating secrets for your application
---

Opta provides built-in secret management for your applications. Any secrets like database passwords, api keys, should not be written in the code (including opta.yml) because if the code is leaked accidentally, your infrastructure is exposed to hackers.

Opta enables you to store these in an encrypted fashion inside the kubernetes
cluster. To use the secrets functionality:

* Define the secrets in the service's opta.yml file
* Use the `opta secret` cli to update the values
* With the next `opta deploy`, these secrets will be visible to your container
    as environment variables.

1. Define secrets in opta.yml:

```yaml
name: my_app
environments:
  - path: "staging/opta.yml"
    name: staging
modules:
  - name: my_app:
    type: k8s-service
    port:
      http: 5000
    image: AUTO
    secrets:
      - MY_SECRET_1
      - MY_SECRET_2
```

2. Update secret
```bash
opta secret update MY_SECRET_1 <value>
```

3. List all secrets
```bash
opta secret list
```

4. View secret value
```bash
opta secret view MY_SECRET_1
```
