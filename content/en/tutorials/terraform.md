---
title: "Generate Terraform"
linkTitle: "Generate Terraform"
date: 2022-01-16
draft: false
description: Guide on how to generate the terraform files
---

## Overview

To provision the infrastructure, Opta uses [Terraform](https://www.terraform.io/), the popular open-source infrastructure as code software.

Opta provides a command callled `generate-terraform` to generate the terraform files.

## Generate the terraform files

Consider an opta environment file for AWS and a service:

{{< tabs tabTotal="2" >}}
{{< tab tabName="opta.yaml" >}}
{{< highlight yaml >}}
# opta.yaml
name: staging # name of the environment
org_name: my-org # A unique identifier for your organization
providers:
  aws:
    region: us-east-1
    account_id: XXXX # Your 12 digit AWS account id
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
{{< / highlight >}}
{{< /tab >}}

{{< tab tabName="hello.yaml" >}}
{{< highlight yaml >}}
# hello.yaml
name: hello
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - type: k8s-service
    name: hello
    port:
      http: 80
    image: ghcr.io/run-x/opta-examples/hello-app:main
    healthcheck_path: "/"
    public_uri: "/hello"
{{< / highlight >}}
{{< /tab >}}

{{< /tabs >}}

1. Generate the terraform files for the environment file

```shell
opta generate-terraform -c opta.yaml
```

```
# generated files in "./generated-terraform"
.
├── modules/                   # Contain the module terraform files
├── data.tf.json               # Data sources definition
├── module-base.tf.json        # Configuration for the base module (VPC, Network)
├── module-k8sbase.tf.json     # Configuration for the base module (Kubernetes add-ons: mesh, load balancer)
├── module-k8scluster.tf.json  # Configuration for the base module (Kubernetes cluster)
├── output.tf.json             # Output values
├── provider.tf.json           # Provider definition (cloud provider info)
├── readme-staging.html        # Documentation on how to use terraform for the environment stack
└── terraform.tf.json          # Backend configuration (local or remote)
```

That's it! Now you can run terraform to provision the infrastructure.  
For more information about the terraform commands check the generated readme file.

Note: this command doesn't connect to the cloud provider, you can generate the terraform files without the cloud credentials.

2. Generate the terraform files for the service file

Now that you have generated the terraform files for the environment, you can proceed to run the same commands for all the other opta config files such as for each service.

```shell
# use the same output directory
opta generate-terraform -c hello.yaml
```

This will add and update some files in the generated directory:
```
# updated files in "./generated-terraform"
.
├── modules/                   # Added the k8s-service module
├── module-hello.tf.json       # Configuration for the k8s-service module
├── output.tf.json             # Updated to include the output related to the service
├── readme-hello.html          # Documentation on how to use terraform for the service stack
```

That's it! Now you can run terraform to provision the service.
For more information about the terraform commands check the generated readme file.

Note: The service depends on the environment creation, for example a service needs to install itself on a Kubernetes cluster. For this reason, the terraform files for the environment and the service need to be exported in the same output directory. The generated terraform code is already modularized so feel free to reorganize it differently if you would like a different layout.

## Migrate from Opta to Terraform

If you have already provisonned your infrastructure with Opta and would like to use terraform instead and keep the existing infrastructure, set the `--backend remote` option.

```shell
opta generate-terraform -c env-file.yaml --backend remote

# repeat for every opta config file
opta generate-terraform -c service-file.yaml --backend remote
```

```
# generated files in "./generated-terraform"
.
├── modules/                   # Contain the module terraform files
├── data.tf.json               # Data sources definition
├── module-base.tf.json        # Configuration for the base module (VPC, Network)
├── module-k8sbase.tf.json     # Configuration for the base module (Kubernetes add-ons: mesh, load balancer)
├── module-k8scluster.tf.json  # Configuration for the base module (Kubernetes cluster)
├── output.tf.json             # Output values
├── provider.tf.json           # Provider definition (cloud provider info)
├── readme-service.html        # Documentation on how to use terraform for the service stack
├── readme-env.html            # Documentation on how to use terraform for the environment stack
└── terraform.tf.json          # Backend configuration, use the existing remote backend
```

That's it! Now you can use terraform to provision the infrastructure.

If you have more than one environment, use  the `--directory` option with a different value for each environment name.

Note: The service depends on the environment creation, for example a service needs to install itself on a Kubernetes cluster. For this reason, the terraform files for the environment and the service need to be exported in the same output directory. The generated terraform code is already modularized so feel free to reorganize it differently if you would like a different layout.

## Support and limitation

- Clouds: AWS, GCP, Azure are supported.
- Modules: Most opta modules are supported except for a few (ex: DNS, Datadog) where Opta does some processing outside of terraform. 

If your configuration uses a module that is not supported, the command will output a warning listing the unsupported modules. For most cases, there will be additional documentation generated in the readme on how to configure these modules outside of terraform.

If you run into an issue or would like extra support, please join our [slack](https://slack.opta.dev/) and reach out to us there.
