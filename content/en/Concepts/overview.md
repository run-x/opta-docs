---
title: "Overview"
linkTitle: "Overview"
draft: false
weight: 1
description: >
  How it works?
---

## How it works?

Opta is based around the concept of Infrastructure-As-Code. You write configuration files and then run the Opta CLI -
which connects to your cloud account and sets things up to reflect the configuration. The Opta CLI can be run from your local machine or a CI/CD system (like jenkins or Github actions).

There are two primary kinds of configuration files:

- **Environment**: This file specifies which cloud/account/region should Opta be set up in. Running Opta on this creates all the
  base resources like a kubernetes cluster, networks, IAM roles, ingress, service mesh, etc. Usually, you'd have 1 env for staging, 1 for
  prod, 1 for qa, etc. You can also do one environment per engineer or pull request - which gives everyone an isolated sandbox to play in!
- **Template**: This file specifies the workload you want to run (usually a microservice). You can also specify any non-k8s resources
  such as a database or some custom Terraform - and Opta will connect them seamlessly.

![Service and environment files link](/images/service_environment_files_linking.png)


## Next steps

- Learn more about [Environment](/concepts/environment/).
