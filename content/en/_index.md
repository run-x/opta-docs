---
title: "Opta"
linkTitle: "Opta"
weight: 20
menu:
  main:
    weight: 20
no_list: true
description: Higher level Infrastructure-As-Code
---

## What is Opta?

Opta is an Infrastructure-As-Code framework where you work with high-level constructs instead of getting lost
in low level cloud configuration. Opta gives you a vast library of modules that you can connect together to
build your ideal Infrastructure stack. Best of all, Opta uses Terraform under the hood - so you're never locked in.
You can always write custom Terraform or even take the Opta generated Terraform and go your own way!

<p align="center">
  <iframe src="https://www.youtube.com/embed/nja_EfpGexE" 
      width="560" 
      height="315"
      frameborder="0" 
      margin: 0 auto;
      allowfullscreen>
  </iframe>
</p>

## Why use Opta
Infrastructure as code (IaC) has rapidly become the standard for provisioning and managing Infrastructure and 
for the right reasons! But the leading IaC tools are still complicated to use and require deep Cloud/Infrastructure
expertise. Opta was conceptualized to help address this complexity. Opta is a simpler IaC framework with best practices
built-in. It enables users to set up automated, scalable and secure infrastructure without being a cloud expert or 
spending days figuring out cloud minutiae!

We are confident it can drastically reduce the cloud complexity and devops headaches of most fast moving 
organizations. It is already being used by companies - big and small :)

To read more about the vision behind Opta, check out this [blog post](https://blog.runx.dev/infrastructure-as-code-for-everyone-7dad6b813cbc).

If you'd like to try it out or have any questions - feel free to join our [Slack](https://slack.opta.dev) or explore the [Getting Started Guide](/getting-started)!

## How it works?

Opta is based around the concept of Infrastructure-As-Code. You write configuration files and then run the Opta CLI -
which connects to your cloud account and sets things up to reflect the configuration. The Opta CLI can be run from your local machine or a CI/CD system (like jenkins or Github actions).

There are two primary kinds of configuration files:

- **Environment**: This file specifies which cloud/account/region should Opta be set up in. Running Opta on this creates all the
  base resources like a kubernetes cluster, networks, IAM roles, ingress, service mesh, etc. Usually, you'd have 1 env for staging, 1 for
  prod, 1 for qa, etc. You can also do one environment per engineer or pull request - which gives everyone an isolated sandbox to play in!
- **Service**: This file specifies the container workload you want to run (usually a microservice). You can also specify any non-k8s
  resources that this container needs - and Opta will connect them seamlessly.

![Service and environment files link](/images/service_environment_files_linking.png)


## Next steps

- Getting started with Opta: [guide](/getting-started)
- Check out more examples: [github](https://github.com/run-x/opta/tree/main/examples)
- Explore all the infrastructure that Opta sets up for you: [Architecture](/architecture/aws/)
- Explore the api for all modules: [Reference](/reference/)
