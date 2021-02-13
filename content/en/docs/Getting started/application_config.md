---
title: "Application configuration"
linkTitle: "Application configuration"
date: 2020-02-01
draft: true
description: >
  Configuration details for the application yaml
---

```yaml
meta:
  name: my_app  # name for your app
  envs:  # the environments where this needs to be deployed
    - parent: "staging/opta.yml"  # path to the env file (could be a github path)
      variables:
        min_size: 5
modules:
  - my_app:  # name for your app
      type: k8s-service  # type of the app
      target_port: 5000  # Change this based on your application container
      domain: "{parent[domain]}"  # optional: used to expose the service to the internet at this domain
      tag: "{tag}"
      env_vars:
        - ENV: "{parent[name]}"
      links:
        my_db: []  # Sets the DB access keys as env variables in your app
      secrets:
        - MY_SECRET
  - my_db:  # Database name
      type: aws-rds  # Type of the database
```
