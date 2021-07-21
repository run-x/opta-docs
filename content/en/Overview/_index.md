---
title: "Overview"
linkTitle: "Overview"
weight: 1
description: >
  What is Opta?
---

Opta is a platform for running containerized workloads in the cloud. It abstracts away the complexity of networking,
IAM, kubernetes, and various other components - giving you a clean cloud agnostic interface to deploy and run your
containers. It's all configuration driven so you always get a repeatable copy of your infrastructure.

With Opta, setting up a new environment takes <30min and setting up a new service
takes <10min. All without any Infra/Cloud/Kubernetes expertise PLUS you get an
industry standard setup (including observability) from Day 1.

## Why should you use Opta?

Modern cloud infrastructure has become an engineering field in and of itself, with a high learning curve and limited
hiring pool. Unfortunately, good cloud infrastructure is also required by software products if one wishes it to
be highly available, scalable and secure.

Opta sets you up with battle tested and industry standard infrastructure out of the box. It's all based on Terraform -
so you can continue to tweak things as needed and even fork off of our standard stack and go your own way (no lock-in).
It also handles a lot of boilerplate stuff like terraform state storage and connecting containers to non-k8s resources
(like RDS). Additionally, Opta provides you a simplified CLI interface to do most common operations (like ssh'ing into
a container, tailing logs, or scaling up/down).

## Opta vs PaaS

While there are platform-as-a-service (PaaS) products in the market offering to
handle the complexity of the cloud providers, running customer applications in their simplified cloud, these products
replace the old problems with new ones. By having a middleman between them and the servers, customers will naturally
have higher infrastructure prices (that's how middleman businesses work), which grow and become more severe as they
scale. Debugging will become more difficult by the same principles. Most importantly of all, the customers will be
surrendering ownership and control of their infrastructure, meaning:

- Difficult integration with custom resources even if the PaaS' underlying cloud provider has it.
- Added delay of release of new features/version from the underlying cloud provider.
- Inheriting deficiencies of the new layer with limited abilities to configure and remediate
- Inheritance of security vulnerabilities.

Opta provides an alternative model by deploying and maintaining resources directly in the cloud provider and under the
customers own account, while yet offering an opinionated framework taking care of default settings and "golden path"
resource integrations automatically. Required infrastructure knowledge is kept to a minimum while the customer reaps
the benefits of "directly" managing their cloud resources.

## How it works?

Opta is based around the concept of Infrastructure-As-Code. You write configuration files and then run the Opta CLI -
which connects to your cloud account and sets things up to reflect the configuration. You can think of it as an alternative
to Terraform or Cloudformation. The Opta CLI can be run from your local machine or a CI/CD system (like jenkins or Github actions).

There are two primary kinds of configuration files:

- Environment: This file specifies which cloud/account/region should Opta be set up in. Running Opta on this creates all the
  base resources like a kubernetes cluster, networks, IAM roles, ingress, service mesh, etc. Usually, you'd have 1 env for staging, 1 for
  prod, 1 for qa, etc. Some folks are also doing one environment per engineer - which gives everyone an isolated sandbox to play in!
- Service: This file specifies the container workload you want to run (usually a microservice). You can also specify any non-k8s
  resources that this container needs - and Opta will connect them seamlessly.

For both files, you just run a single command `opta apply` and the magic happens!

## Where should I go next?

Read the [Getting Started Guide](/getting-started/).
