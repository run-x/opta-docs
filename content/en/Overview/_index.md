---
title: "Overview"
linkTitle: "Overview"
weight: 1
description: Opta overview and benefits
---

# What is Opta?

Opta, built on [Terraform](https://www.terraform.io), is an Infrastructre as Code tool that efficiently and repeatably provisions containterized cloud infrastructure and applications.  

- create highly available, scalable, and secure environments with Infrastructure as Code

- integrate with AWS, GCP, and Azure cloud providers

- manage the entire cloud infrastructure lifecycle

<!---
*Image*: 
CONFIGURE > CODE > PROVISION > RETIRE
--->

# What are the Opta Benefits?
Opta removes the complexity of managing cloud infrastructure.  

Managing modern cloud infrastructure has become a specialized discipline and Opta can overcome these challenges:  
- high learning curve
- limited hiring pool
- ongoing cost

## Infrastructure as Code

Automate the lifecycle of your cloud infrastructure to provision, deploy, monitor, and retire cloud resources based on project needs.

- reusable configuration file
- <30 minutes to be environment ready
- industry standard setup  
 
## Opta is open source
Opta is open source, enabling you to customize as needed. Fork our standard stack and create your own solution. Check out the [Opta GitHub repository](https://github.com/run-x/opta-docs).  

## Terraform integration
Using proven technology, manage standard Terraform resources in the Opta configuration file.
- network
- security groups
- virtual servers
- load balancer 

Opta links resources including non-kubernetes resources:
- RDS
- Cloud SQL
- DocumentDB


## Command line interface (CLI)
Opta has a simplified CLI interface to do most common operations: 
- ssh into a container
- tailing logs
- scaling up or down

## Opta advantage over Platform as a Service (PaaS)
PaaS incurs a high cost for managing cloud resources. Opta achieves the same services with reduced cost. However, you:
- maintain control over your environment 
- build and deploy infrastructure where and when you want
- reduce cost of cloud resource management

# How Does Opta Work?

Execute the Opta configuration files using the CLI from either your local machine or a CI/CD system like jenkins or Github actions. Running the Opta CLI:
- connects to your cloud account
- provisions the infrastructure as designed
- launches the application workload service
- retires infrastructure as needed

There are two primary configuration file types: environment and service. For both files, run the single command `opta apply` and the magic happens! 

## Environment configuration file
The environment file specifies which cloud provider, account, and region should Opta be set up in. Running the Opta environment file creates base resources, such as:
- kubernetes cluster
- networks
- IAM roles
- ingress
- service mesh  

Use Opta to quickly create each of the Staging, QA, and Production environments. Some folks are also creating one environment per engineer which gives everyone an isolated sandbox to play in!

## Service configuration file
The service file specifies the container workload to run (usually a microservice). Specify any non-kubernetes resources that this container needs and Opta will connect them seamlessly.

# Where should I go next?

Read the [Getting Started Guide](/getting-started/)  

Watch a [demo of Opta](https://www.youtube.com/watch?v=nja_EfpGexE)  

Read about using [Opta templates](/miscellaneous/templatization/)

