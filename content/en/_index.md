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

Opta is an infrastructure-as-code framework. Rather than working with
low-level cloud configuration, Opta enables you to work with high-level
constructs.

Opta high-level constructs produce Terraform configuration files. This helps
you avoid lock-in to Opta. You can write custom Terraform code or even take the
Opta-generated Terraform and go your own way.

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

Infrastructure-as-code (IaC) has become the standard for provisioning and
managing infrastructure. Leading IaC tools are complicated to use and require
cloud and infrastructure expertise that is difficult to maintain unless DevOps
is your full-time job.

Opta is a simpler IaC framework with cloud and infrastructure best practices
built in. It enables users to set up automated, scalable, and secure
infrastructure in a relatively small amount of time and without being a cloud
expert.

To read more about the vision behind Opta, see the article
[Infrastructure as Code for Everyone](https://blog.runx.dev/infrastructure-as-code-for-everyone-7dad6b813cbc).

To try Opta, follow our [Getting Started Guide](/getting-started).

To ask questions and participate in our community in other ways, join our
[Slack](https://slack.opta.dev).

## How it works?

With Opta you write configuration files and then use the Opta command-line
interface (CLI). The Opta CLI connects to your cloud account and configures
your infrastructure to your specifications using Terraform. You can run the
Opta CLI from your local machine or a CI/CD system (like Jenkins or Github
actions).

There are two primary types of Opta configuration files.

### Environment

Environment files specify which cloud, account, and region to configure
infrastructure in. From this file, Opta will create all the
base resources, including: kubernetes clusters, networks, IAM roles, ingress,
service mesh, etc. Usually, you'll have one environment file for staging, one
for production, one for quality assurance (QA), etc.

You can also create one environment per engineer or pull request, which gives
each member of your team an isolated development sandbox.

### Service

Service files specify the container workload you want to run (usually a
microservice). You can also specify any non-Kubernetes resources that this
container needs and Opta will connect them seamlessly.

![Service and environment files link](/images/service_environment_files_linking.png)


## Next steps

- Follow the Opta [Getting Started](/getting-started) guide.
- Explore [Opta Examples](https://github.com/run-x/opta/tree/main/examples)
- Review [Opta's Architecture](/architecture/aws/)
- Explore the [Opta API](/reference/)
