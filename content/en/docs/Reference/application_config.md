---
title: "Application configuration"
linkTitle: "Application configuration"
date: 2020-02-01
description: >
  Configuration details for the application yaml
---

```yaml
meta:
  name: MyApp  # name for your app
  envs:  # the environments where this needs to be deployed
    - parent: "staging/opta.yml"  # path to the env file (could be a github path)
      variables:
        min_size: 5
  variables:
    tag: ""
modules:
  - MyApp:  # name for your app
      type: k8s-service  # type of the app
      target_port: 5000  # Change this based on your application container
      domain: "{parent[domain]}"  # optional: used to expose the service to the internet at this domain
      tag: "{tag}"
      env_vars:
        - _link: MyRdsDb  # Sets the DB access keys as env variables in your app
        - ENV: "{parent[name]}"
      secrets:
        - MY_SECRET
  - MyRdsDb:  # Database name
      type: aws-rds  # Type of the database
```
