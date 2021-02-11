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
Check out the [Installation instructions](/docs/installation).

## Environment creation
In this step we will create an environment (example staging, qa, prod) for your organization.
For this we need to create an `opta.yml` file which defines the environment.

Create the following file at `staging/opta.yml` directory and update the fields specific to your AWS account setup.
```yaml
meta:
  name: staging
  # Provide a unique org_id here, usually your company name
  org_id: runx
  providers:
    aws:
      # Provide your AWS account and region here
      region: us-east-1
      allowed_account_ids: [ 889760294590 ]
  variables:
    # Provide your domain here, assuming you own startup.com :)
    domain: "staging.startup.com"

_init: {}
```

Now, cd to the `staging` dir and run:
```bash
opta apply
```

This step will create an EKS cluster for you and set up VPC, networking and various other infrastructure pieces transparently.

_Note: using a domain needs extra setup, please check out the [Ingress docs](/docs/reference/ingress)._

## Service creation
In this step we will create a service with your application's logic.
We will create another `opta.yml` file, which defines high level configuration of this service.

Create this file at `my_app/opta.yml` and update the fields specific to your service setup.

```yaml
meta:
  name: my_app 
  envs:
    # The environment to deploy to
    - parent: "staging/opta.yml"
modules:
  - my_app:
      type: k8s-service
      # This is needed for deploys to work properly!
      tag: "{tag}"
      # The docker port your service listens on
      target_port: 5000
      # The path to expose this app on
      domain: "my_app.{parent[domain]}"
      env_vars:
        # Use parent variables to distinguish b/w various environments
        - ENV: "{parent[name]}"
      links: 
        # DB credentials will be passed down to your app as env variables
        my_db: []
      secrets:
        - MY_SECRET
  - my_db:
      type: aws-rds
```

Now, cd to the `my_app` dir and run:
```bash
opta apply
```
This sets up your service's infrastructure (database, etc) and now it's ready to be deployed
(next section).

## Service Deployment

To deploy the service:
- Build docker image: `docker build ...`
- Upload docker image: `opta push --tag <tag> image` where `<tag>` is what you want to call this version. Usually the git sha.
- Apply the change: `opta apply --var tag=<tag>`

Now your service will be accessible at https://my_app.staging.startup.com! Congrats!
