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
  - type: aws-eks
  - type: k8s-base
```

Now, cd to the `staging` dir and run:
```bash
opta apply
```

This step will create an EKS cluster for you and set up VPC, networking and various other infrastructure pieces transparently.

_Note: while we create the "domain" setting it up so that it actually receives internet traffic and has ssl takes some extra 
steps, please check out the [Ingress docs](/docs/tutorials/ingress)._

## Service creation
In this step we will create a service with your application's logic.
We will create another `opta.yml` file, which defines high level configuration of this service.

Create this file at `myapp/opta.yml` and update the fields specific to your service setup.

```yaml
environments:
  - name: staging
    path: "../new_env/opta.yml"
    vars:
      - max_containers: 2
name: hello-world
modules:
  - name: app
    type: k8s-service
    image: "AUTO"
    min_containers: 2
    max_containers: "{vars.max_containers}"
    liveness_probe_path: "/get"
    readiness_probe_path: "/get"
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

Now, cd to the `myapp` dir and run:
```bash
opta apply
```
This sets up your service's infrastructure (database, private docker repo, etc) and now it's ready to be deployed
(next section).

## Service Deployment
In the example above, we created all the resources for the service except the actual deployment. This is because we do
not have a docker image for it in the cloud yet. To deploy, we need to first build the image, push it, and then apply
the yaml again, this time specifying the now existing remote image and tag. You can do so by following these steps to 
deploy the service:

- Build docker image: `docker build -t test-service:v1 ...` set v1 to what you want to call this version. Usually the git sha
  (if you don't have a dockerfile ready you can always pull an existing image and retag it `docker pull kennethreitz/httpbin && docker tag kennethreitz/httpbin:latest test-service:v1`)
- Upload docker image: `opta push test-service:v1`
- Apply the change: `opta apply ---image-tag v1`

Now, once this step is complete, you should be to curl your service by specifying the url of the load balancer we
created for you (again, can't use the domain until you finish the extra ingress steps outlined in the tutorial, but
you can totally hit the load balancer directly) and setting the host header to match your desired domain:
```bash
opta configure-kubectl
export DOMAIN=`kubectl get services -n ingress-nginx ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
curl --header "Host: subdomain.staging.example.com"  http://${DOMAIN}/get # NOTE: not https because ssl is part of the extra setup
```

To fully setup the public dns and ssl, please checkout the [Ingress docs](/docs/tutorials/ingress).