---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 2
description: >
  The first steps in working with Opta.
---


## Prerequisites
Opta currently has the following system prerequisites to operate normally:
* A supported macos or debian distro release.
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [terraform](https://www.terraform.io/downloads.html) (v0.14+)
* [docker](https://docker.com/products/docker-desktop) (v19+)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (also packaged with 
  docker-for-mac)

## Installation
> Latest version: 0.4

### MacOS or Linux
```
/bin/bash -c "$(curl -fsSL https://docs.runx.dev/install.sh)"
```

## Env creation
In this step we will create an environment (example staging, qa, prod) for your organization.
For this we need to create an `opta.yml` file which defines the environment.

Create the following file at `staging/opta.yml` directory and update the fields specific to your AWS account setup.
```
meta:
  name: staging
  providers:
    aws:
      region: us-east-1
      allowed_account_ids: [ 889760294590 ]  # replace this with your AWS account id
  variables:
    domain: "staging.example.com"  # replace this with a domain you own
    datadog_api_key: ""

_init: {}
```
Save this file at `staging/opta.yml` and run:
```
opta apply staging/opta.yml
```

This step will create an EKS cluster for you and set up VPC, networking and various other infrastructure pieces transparently.

## Service creation
In this step we will create a service with your application's logic.
We will create another `opta.yml` file, which defines high level configuration of this service.

Create this file at `MyApp/opta.yml` and update the fields specific to your service setup.

```
meta:
  name: MyApp 
  envs:
    - parent: "staging/opta.yml"
      variables:
        ENV: staging # You can set any environment variables you want here
  variables:
    tag: ""
modules:
  - MyApp:
      type: k8s-service
      target_port: 5000  # Change this based on your
      domain: "{parent[domain]}"  # optional: used to expose the service to the internet at this domain
      tag: "{tag}"
      env_vars:
        - _link: MyRdsDb  # This is defined below
        - ENV: "{parent[name]}"
      secrets:
        - ALGOLIA_ADMIN_KEY
  - MyRdsDb:
      type: aws-rds  # Creates an AWS RDS DB for you
```

Save this file at `MyApp/opta.yml` and run:
```
opta apply MyApp/opta.yml
```
Now your service's infrastructure and networking is ready to be deployed

## Service Deployment
TBD
