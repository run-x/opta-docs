---
title: "GCP"
linkTitle: "GCP"
weight: 2
description: >
  Getting started with Opta on GCP.
---

## Installation

One line installation ([detailed instructions](/installation)):

```
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

Make sure the gcp cloud credentails are configured in your terminal.

## Environment creation

In this step we will create an environment (example staging, qa, prod) for your organization.

You can use the CLI option described below or checkout our [interactive app](https://app.runx.dev/yaml-generator) to build your first environment and service.


Start by running:

```bash
opta init env gcp
```

This will create an `env.yml` file with initial configurations for your environment. Below are examples of the resulting yaml files for each environment.

```yaml
name: staging # A unique identifier for your environment
org_name: runx # A unique identifier for your organization
providers:
  google:
    region: us-central1 # Your gcp region. You can find a list of them here: https://cloud.google.com/compute/docs/regions-zones
    project: my-project-name-1234 # the name of your GCP project
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
```

Now, run:

```bash
opta apply
```

This step will create an GKE cluster for you and set up networking and various other infrastructure pieces.

## Service creation

In this step we will create a service - which is basically a docker container and associated database.
We will create another `service.yml` file, which defines high level configuration of this service.

To get started, run

```bash
opta init service <YOUR_ENV_FILE_PATH> k8s
```

This will prompt you for some information and create a starting
point for your `service.yml` file. Then, update the fields specific to your service setup. You can see examples of resulting files below.


```yaml
name: hello-world # service names are unique per-environment
environments:
  - name: staging
    path: "env.yml"
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

Now you are ready to deploy your service.

## Service Deployment

One line deployment:

```bash
opta apply
```

Now, once this step is complete, you should be to curl your service by specifying the load balancer url/ip.

Run `output` and note down load_balancer_raw_ip`.

Now you can:

- Access your service at http://\<ip\>/
- SSH into the container by running `opta shell`
- See logs by running `opta logs`

## Cleanup

Once you're finished playing around with these examples, you may clean up by running the following command from the environment directory:

```bash
opta destroy
```

## Next steps

- Check out more examples: [github](https://github.com/run-x/opta/tree/main/examples)
- Use your own docker image: [Custom Image](/tutorials/custom_image)
- Set up a domain name for your service: [Ingress](/tutorials/ingress)
- Use secrets: [Secrets](/tutorials/secrets/)
- Set up observability integrations in one line(!): [Observability](/observability/)
- Explore all the infrastructure that Opta sets up for you: [Architecture](/architecture/gcp/)
- Explore the api for all modules: [Reference](/reference/google/)
