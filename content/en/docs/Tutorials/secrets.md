---
title: "Secrets"
linkTitle: "Secrets"
date: 2020-02-01
description: >
  Creating secrets for your application
---

Opta provides in-built secret management for your applications.
* Define the secrets in the service's opta.yaml file.
* Use the `opta secret` cli to update the value and list secrets.

1. You can define/provision all the secrets you would need for an application in the service's opta.yaml file like this:

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

2. Now you can use the following command (from the dir where above file) to list all your secrets
```bash
opta secret list MyApp --env staging
```

3. To set the values of the secrets, you can use the cli
```bash
opta secret update MyApp MY_SECRET_1 SECRET_VALUE --env staging
```
Note: The secret needs to be set individually for each service and environment

4. You can print the value of an existing secret with the cli
```bash
opta secret view MyApp MY_SECRET_1 --evn staging
```
