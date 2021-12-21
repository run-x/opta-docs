---
title: "Opta"
linkTitle: "Opta"
weight: 20
menu:
  main:
    weight: 20
no_list: true
description: Create secure, scalable, compliant Infrastructure stack for your startup in less than an hour.
---

## What is Opta?

Opta is a new kind of Infrastructure-As-Code framework where you work with high-level constructs
instead of getting lost in low level cloud configuration. Imagine just being able to say that you want
an autoscaling docker container that talks to a RDS database - instead of figuring out the details of VPC,
IAM, Kubernetes, Elastic Load Balancing etc -- that's what Opta does!

<p align="center">
  <iframe src="https://www.youtube.com/embed/nja_EfpGexE" 
      width="560" 
      height="315"
      frameborder="0" 
      margin: 0 auto;
      allowfullscreen>
  </iframe>
</p>

## Who is it for?

Opta is designed for folks who are not Infrastructure or Devops experts but still want to build amazing,
scalable, secure Infra in the cloud. Majority of Opta's users are early stage startups who use it for their
dev/staging/production environments.

If you'd like to try it out or have any questions - feel free to join our [Slack](https://slack.opta.dev/)!

## What you get with Opta

- Production ready [Architecture](https://docs.opta.dev/architecture/aws/)
- SOC2 compliance from day 1
- Continuous Deployment for containerized workloads
- Hardened network and security configurations
- Support for multiple environments (like Dev/QA/Staging/Prod)
- Integrations with observability tools (like Datadog/LogDNA/Prometheus/SumoLogic)
- Support for non-kubernetes resources like RDS, Cloud SQL, DocumentDB etc
- Built-in auto-scaling and high availability (HA)
- Support for spot instances

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
