---
title: "Overview"
linkTitle: "Overview"
weight: 1
description: >
  What is Opta?
---


Opta, is a cloud infrastructure management tool specifically designed to reduce
complexity and improve iteration speed. 

Opta enables you to set up infra on your AWS account via high-level config files
(that describe microservices and databases) and low level details like access 
permissions, network and secret management are handled automatically.

This way setting up a new environment takes <30min and setting up a new service 
takes <10min. All without any Infra/AWS/Kubernetes expertise PLUS you get an 
industry standard setup (including monitoring) from day 1.

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

Opta provides an alternative model by deploying and maintaining resources directly in the cloud provider and under the
customers own account, while yet offering an opinionated framework taking care of default settings and "golden path"
resource integrations automatically. Required infrastructure knowledge is kept to a minimum while the customer reaps
the benefits of "directly" managing their cloud resources.

### What is it good for?
Opta was designed with the following use cases in mind:
  - A young startup seeking to quickly create reliable and scalable infrastructure while keeping their engineers 
    focused on the app.
  - A mature business seeking to move legacy infrastructure to the cloud.

## Where should I go next?

Read the [Getting Started Guide](/docs/getting-started/) or check out some [Examples](/docs/examples/).
