---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 2
description: >
  The first steps in working with Opta.
---


## Installation
One line installation ([detailed instructions](/installation)):
```
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

Opta works on AWS, GCP, and Azure - so make sure the appropriate cloud credentails are configured in your terminal.

## Environment creation
In this step we will create an environment (example staging, qa, prod) for your organization.
For this we need to create an `opta.yml` file which defines the environment.

Create the following file at `staging/opta.yml` and update the fields specific to your AWS/GCP/Azure account setup.
{{< tabs tabTotal="2" tabID="1" tabName1="AWS" tabName2="GCP" tabName3="Azure" >}}
{{< tab tabNum="1" >}}
```yaml
name: aws-staging
org_name: runx # Add your own name/org_name -- the name + org_name must be universally unique
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
```
{{< /tab >}}
{{< tab tabNum="2" >}}
```yaml
name: gcp-staging
org_name: runx # Add your own name/org_name -- the name + org_name must be universally unique
providers:
  google:
    region: us-central1
    project: XXX
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
```
{{< /tab >}}
{{< tab tabNum="3" >}}
```yaml
name: azure-staging
org_name: runx # Add your own name/org_name -- the name + org_name must be universally unique
providers:
  azurerm:
    location: centralus
    tenant_id: XXX
    subscription_id: YYY
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
```
{{< /tab >}}
{{< /tabs >}}
Now, cd to the `staging` dir and run:
```bash
opta apply
```

This step will create an EKS cluster for you and set up VPC, networking and various other infrastructure pieces.

## Service creation
In this step we will create a service - which is basically a docker container and associated database.
We will create another `opta.yml` file, which defines high level configuration of this service.

Create an `opta.yml` and update the fields specific to your service setup.
{{< tabs tabTotal="2" tabID="2" tabName1="AWS" tabName2="GCP" tabName2="Azure" >}}
{{< tab tabNum="1" >}}
```yaml
name: hello-world
environments:
  - name: staging
    path: "staging/opta.yml"
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: docker.io/kennethreitz/httpbin:latest # Or you can specify your own
    healthcheck_path: "/get"
    public_uri: all
    links:
      - db
  - name: db
    type: postgres # Will spawn a RDS database and credentials will be passed via env vars
```
{{< /tab >}}
{{< tab tabNum="2" >}}
```yaml
name: hello-world
environments:
  - name: staging
    path: "staging/opta.yml"
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: docker.io/kennethreitz/httpbin:latest # Or you can specify your own
    healthcheck_path: "/get"
    public_uri: all
    links:
      - db
  - name: db
    type: postgres # Will spawn a Cloud SQL database and credentials will be passed via env vars
```
{{< /tab >}}
{{< tab tabNum="3" >}}
```yaml
name: hello-world
environments:
  - name: staging
    path: "staging/opta.yml"
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: docker.io/kennethreitz/httpbin:latest # Or you can specify your own
    healthcheck_path: "/get"
    public_uri: all
    links:
      - db
  - name: db
    type: postgres # Will spawn a Cloud SQL database and credentials will be passed via env vars
```
{{< /tab >}}
{{< /tabs >}}

Now you are ready to deploy your service.

## Service Deployment
One line deployment:
```bash
opta apply
```

Now, once this step is complete, you should be to curl your service by specifying the load balancer url/ip.

Run `output` and note down `load_balancer_raw_dns` (AWS) or `load_balancer_raw_ip` (GCP and Azure).

Now you can:
- Access your service at http://\<ip-or-dns\>/
- SSH into the container by running `opta shell`
- See logs by running `opta logs`

## Cleanup
Once you're finished playing around with these examples, you may clean up by running the following command from the environment directory:
```bash
opta destroy
```

## Next steps
- Check out more examples: [github](https://github.com/run-x/opta/tree/main/examples)
- Use your own docker image: [Custom Image](/miscellaneous/custom_image)
- Set up a domain name for your service: [Ingress](/miscellaneous/ingress)
- Use secrets: [Secrets](/miscellaneous/secrets/)
- Set up observability integrations in one line(!): [Observability](/observability/)
- Explore all the infrastructure that opta sets up for you: [Architecture](/architecture/)
- Explore the api for all modules: [Reference](/modules-reference/)
