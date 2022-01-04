---
title: "Azure"
linkTitle: "Azure"
weight: 3
description: >
  Getting started with Opta on Azure.
---

To use Opta, you first need to create some simple yaml configuration files that describe your needs. You can use our [**Magical UI**](https://app.runx.dev/yaml-generator) to help generate these files or do it manually (described below).

## Installation

One line installation ([detailed instructions](/installation)):

```
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

Make sure the Azure cloud credentials are configured in your terminal.

## Environment creation

Before you can deploy your app, you need to first create an environment (like staging, prod etc.)
This will set up the base infrastructure (like network and cluster) that will be the foundation for your app.

> Note that it costs around $5 per day to run this on Azure. So make sure to destroy it after you're done 
> (opta has a destroy command so it should be easy :))!

Create this file and name it `staging.yaml`

```yaml
name: staging
org_name: <something_unique> # A unique identifier for your organization
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

Now, run:

```bash
opta apply -c staging.yaml
```

For the first run, this step takes approximately 15 min.  
It will create an AKS cluster and set up the networking and various other infrastructure pieces.  
For more information about what is created, see [Azure Architecture](/architecture/azure/).

## Service creation

In this step we will create a service - which is basically a docker container.
In this example we are using the popular [httbin](https://httpbin.org/) container as our application.


Create this file and name it `hello_world.yaml`

```yaml
name: hello-world
environments:
  - name: staging
    path: "staging.yaml" # Note that this is the file we created in step 2
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: docker.io/kennethreitz/httpbin:latest
    healthcheck_path: "/get"
    public_uri: "all"
```


Now you are ready to deploy your service.

## Service Deployment

One line deployment:

```bash
opta apply -c hello_world.yaml
```

Now, once this step is complete, you should be to curl your service by specifying the load balancer url/ip.

Run `output` and note down `load_balancer_raw_ip`.

Now you can:

- Access your service at http://\<ip\>/
- SSH into the container by running `opta shell`
- See logs by running `opta logs`

## Cleanup

Once you're finished playing around with these examples, you may clean up by running the following command from the environment directory:

```bash
opta destroy -c hello_world.yaml
opta destroy -c staging.yaml
```

## Next steps

- Check out more examples: [github](https://github.com/run-x/opta/tree/main/examples)
- Use your own docker image: [Custom Image](/tutorials/custom_image)
- Set up a domain name for your service: [Ingress](/tutorials/ingress)
- Use secrets: [Secrets](/tutorials/secrets/)
- Set up observability integrations in one line(!): [Observability](/observability/)
- Explore all the infrastructure that Opta sets up for you: [Architecture](/architecture/azure)
- Explore the api for all modules: [Reference](/reference/azurerm)
