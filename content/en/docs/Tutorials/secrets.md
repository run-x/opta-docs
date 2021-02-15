---
title: "Secrets"
linkTitle: "Secrets"
date: 2020-02-01
description: >
  Creating secrets for your application
---

Opta provides in-built secret management for your applications. Any secrets like database passwords, api keys, should not be written in the code (including opta.yml) because if the code is leaked accidentally, your infrastructure is exposed to hackers. Hence we store these secrets in a specific secret store. To use the secrets functionality:

* Define the secrets in the service's opta.yml file.
* Use the `opta secret` cli to update the value and list secrets.

1. You can define/provision all the secrets you would need for an application in the service's opta.yml file like this:

```yaml
meta:
  name: my_app
  envs:
    - parent: "staging/opta.yml"
modules:
  - my_app:
      type: k8s-service
      target_port: 5000
      tag: "{tag}"
      env_vars:
        - ENV: "{parent[name]}"
      secrets:
        - MY_SECRET_1
        - MY_SECRET_2
```

So when you run `opta apply` on this file, it will provision the secrets for you.

2. Now you can use the following command (from the dir where above file is located) to list all your secrets
```bash
opta secret list my_app --env staging
```

3. To set the values of the secrets, you can use the cli
```bash
opta secret update my_app MY_SECRET_1 SECRET_VALUE --env staging
```
Note: The secret needs to be set individually for each service and environment

4. You can print the value of an existing secret with the cli
```bash
opta secret view my_app MY_SECRET_1 --env staging
```
