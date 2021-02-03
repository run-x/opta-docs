---
title: "Overview"
linkTitle: "Overview"
weight: 1
description: >
  What is the Runx CLI?
---


The Runx CLI, runxc, is an opinionated cloud infrastructure setup tool designed to handle the default resources and
settings, allowing the user to focus on their app. It takes as input a yaml file containing the specification
of the resources required, and then uses [terraform](https://www.terraform.io/) under the hood to create said 
resources and keep track of state changes. It is designed to be cloud agnostic but for now it only support 
[AWS](https://aws.amazon.com/) as a  provider, and [Kubernetes](https://kubernetes.io/) for application deployment.

## Why do I want it?

Modern cloud infrastructure has become an engineering field in and of itself, with a high learning curve and limited
hiring pool. Unfortunately, good cloud infrastructure is also required by software products if one wishes it to
be highly available and scalable. While there are platform-as-a-service (PaaS) products in the market offering to 
handle the complexity of the cloud providers, running customer applications in their simplified cloud, these products
replace the old problems with new ones. By having a middleman between them and the servers, customers will naturally
have higher infrastructure prices (that's how middleman businesses work), which grow and become more severe as they
scale. Debugging will become more difficult by the same principles. Most importantly of all, the customers will be
surrendering ownership and control of their infrastructure, meaning:
* Difficult integration with custom resources even if the PaaS' underlying cloud provider has it.
* Added delay of release of new features/version from the underlying cloud provider.
* Inheriting deficiencies of the new layer with limited abilities to configure and remediate
* Inheritance of security vulnerabilities.

Runxc provides an alternative model by deploying and maintaining resources directly in the cloud provider and under the
customers own account, while yet offering an opinionated framework taking care of default settings and "golden path"
resource integrations automatically. Required infrastructure knowledge is kept to a minimum while the customer reaps
the benefits of "directly" managing their cloud resources.

### What is it good for?
Runxc was designed with the following use cases in mind:
  - A young startup seeking to quickly create reliable and scalable infrastructure while keeping their engineers 
    focused on the app
  - A mature business seeking to move legacy infrastructure to the cloud.

## Where should I go next?

Give your users next steps from the Overview. For example:

* [Getting Started](/docs/getting-started/): Get started with runxc
* [Examples](/docs/examples/): Check out some example code!

