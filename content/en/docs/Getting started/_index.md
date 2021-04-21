---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 2
description: >
  The first steps in working with Opta.
---


## Installation
Check out the [Installation instructions](/docs/installation).

Make sure, your AWS credentials are configured in the terminal for the AWS account you will use in this exercise.

## Environment creation
In this step we will create an environment (example staging, qa, prod) for your organization.
For this we need to create an `opta.yml` file which defines the environment.

Create the following file at `staging/opta.yml` and update the fields specific to your AWS/GCP account setup.
{{< tabs tabTotal="2" tabID="1" tabName1="AWS" tabName2="GCP" >}}
{{< tab tabNum="1" >}}
```yaml
name: aws-staging
org_name: runx # Add your own name/org_name -- the name + org_name must be universally unique
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: aws-base
  - type: aws-dns
    domain: staging.mydomain.com
    delegated: false
  - type: aws-eks
    node_instance_type: t3.medium  # Optional
    max_nodes: 15  # Optional
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
  - type: gcp-base
  - type: gcp-dns
    domain: staging.mydomain.com
    subdomains: # Need to specify supported subdomains individually for GCP
      - app 
    delegated: false
  - type: gcp-gke
    node_instance_type: "n2-highcpu-4" # Optional
    max_nodes: 15  # Optional
  - type: gcp-k8s-base
```
{{< /tab >}}
{{< /tabs >}}
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
{{< tabs tabTotal="2" tabID="2" tabName1="AWS" tabName2="GCP" >}}
{{< tab tabNum="1" >}}
```yaml
name: hello-world
environments:
  - name: staging
    path: "staging/opta.yml"
    vars:
      min_containers: 1
      max_containers: 3
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    public_uri: "app.{parent.domain}"
    image: AUTO
    resource_request:
      cpu: 100  # in millicores
      memory: 512  # in megabytes
    min_containers: "{vars.min_containers}"
    max_containers: "{vars.max_containers}"  # autoscales to this limit
    healthcheck_path: "/get"
    env_vars:
      - name: APPENV
        value: "{env}"
    links:
      - db
    secrets: # Checkout the secrets tutorial on how to use these
      - API_KEY
  - name: db
    type: aws-postgres
```
{{< /tab >}}
{{< tab tabNum="2" >}}
```yaml
environments:
  - name: staging
    path: "staging/opta.yml"
    variables:
      max_containers: 2
name: hello-world
modules:
  - name: app
    type: gcp-k8s-service
    port:
      http: 80
    public_uri: "app.{parent.domain}"
    image: AUTO
    resource_request:
      cpu: 100  # in millicores
      memory: 512  # in megabytes
    min_containers: "{vars.min_containers}"
    max_containers: "{vars.max_containers}"  # autoscales to this limit
    healthcheck_path: "/get"
    env_vars:
      - name: APPENV
        value: "{env}"
    links:
      - db
    secrets: # Checkout the secrets tutorial on how to use these
      - API_KEY
  - name: db
    type: gcp-postgres
```
{{< /tab >}}
{{< /tabs >}}

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
curl --header "Host: app.staging.mydomain.com"  http://${DOMAIN}/get
```

- To fully setup the public dns and ssl, please checkout the [Ingress docs](/docs/tutorials/ingress).
- Run `opta` to check various other options the cli provides, like streaming logs, or ssh into your container.

## Cleanup
Once you're finished playing around with these examples, you may clean up by running the following command from the environment directory:
```bash
opta destroy
```
