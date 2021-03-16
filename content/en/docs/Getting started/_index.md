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
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) (v2)
* [terraform](https://www.terraform.io/downloads.html) (v0.14+)
* [docker](https://docker.com/products/docker-desktop) (v19+)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (also packaged with 
  docker-for-mac)

## Installation
Check out the [Installation instructions](/docs/installation).

## Environment creation
In this step we will create an environment (example staging, qa, prod) for your organization.
For this we need to create an `opta.yml` file which defines the environment.

Create the following file at `staging/opta.yml` and update the fields specific to your AWS account setup.
```yaml
name: staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: aws-base
  - type: aws-dns
    domain: staging.example.com
    delegated: false
  - type: aws-eks
    node_instance_type: t3.medium  # Optional
    max_nodes: 15  # Optional
  - type: k8s-base
```

Now, cd to the `staging` dir and run:
```bash
opta apply
```

This step will create an EKS cluster for you and set up VPC, networking and various other infrastructure pieces transparently.

_Note: while we create the "domain", setting it up so that it actually receives internet traffic and has ssl takes some extra 
steps, please check out the [Ingress docs](/docs/tutorials/ingress)._

## Service creation
In this step we will create a service with your application's logic.
We will create another `opta.yml` file, which defines high level configuration of this service.

Create an `opta.yml` and update the fields specific to your service setup.

```yaml
environments:
  - name: staging
    path: "staging/opta.yml"
    variables:
      - max_containers: 3
name: hello-world
modules:
  - name: app
    type: k8s-service
    image: AUTO
    resource_request:
      cpu: 100  # in millicores
      memory: 512  # in megabytes
    min_containers: 2
    max_containers: "{var.max_containers}"  # autoscales to this limit
    healthcheck_path: "/get"
    port:
      http: 80
    env_vars:
      - name: APPENV
        value: "{env}"
    public_uri: "subdomain.{parent.domain}"
    links:
      - db
    secrets: # Checkout the secrets tutorial on how to use these
      - API_KEY
      - SECRET_1
  - name: db
    type: aws-postgres
```

Now you are ready to deploy your service.

## Service Deployment
In the example above, we have created all the resources for the environment but haven't yet created the resources for the service. We also haven't deployed your container to the service. Both of these things happens in a single next step. 
To deploy, we need to first build the image, push it, and then apply
the yaml again, this time specifying the now existing remote image and tag. You can do so by following these steps to 
deploy the service:

- Build docker image: `docker build -t test-service:v1 ...` set v1 to what you want to call this version. Usually the git sha. In this example you can pull an existing image and retag it
```bash
docker pull kennethreitz/httpbin && docker tag kennethreitz/httpbin:latest test-service:v1
```
- Deploy:
```bash
opta deploy --image test-service:v1
```

Now, once this step is complete, you should be to curl your service by specifying the url of the load balancer we
created for you (again, can't use the domain until you finish the extra ingress steps outlined in the tutorial, but
you can totally hit the load balancer directly) and setting the host header to match your desired domain:
```bash
opta configure-kubectl
export DOMAIN=`kubectl get services -n ingress-nginx ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
curl --header "Host: subdomain.staging.example.com"  http://${DOMAIN}/get # NOTE: not https because ssl is part of the extra setup
```

- To fully setup the public dns and ssl, please checkout the [Ingress docs](/docs/tutorials/ingress).
- Run `opta` to check various other options the cli provides, like streaming logs, or ssh into your container.
