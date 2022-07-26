---
title: "Terraform Generator"
linkTitle: "Terraform Generator"
date: 2022-01-16
draft: false
description: Guide on how to generate the terraform files
---

## Overview

To provision the infrastructure, Opta uses [Terraform](https://www.terraform.io/), the popular open-source infrastructure as code software.

Opta provides a command called `generate-terraform` to generate the terraform files.

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
    image: ghcr.io/run-x/hello-opta/hello-opta:main
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
# generated files:
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

This will generate a new output directory:
```
# updated files in "./generated-terraform"
.
├── modules/                   # Contain the k8s-service module
├── data.tf.json               # Data sources definition
├── module-hello.tf.json       # Configuration for the k8s-service module
├── output.tf.json             # Output values
├── provider.tf.json           # Provider definition (cloud provider info)
├── readme-hello.html          # Documentation on how to use terraform for the service stack
└── terraform.tf.json          # Backend configuration (local or remote)
```

That's it! Now you can run terraform to provision the service.
For more information about the terraform commands check the generated readme file.

## Migrate from Opta to Terraform

If you have already provisonned your infrastructure with Opta and would like to use terraform instead and keep the existing infrastructure, you can use `generate-terraform` to generate the terraform files.  
Once you have generated these files, you can start using terraform to provision your infrastucture instead of opta. Once you have migrated, you can make some changes to your infrastructure by updating the terraform files.

1. Make sure to run `opta apply` on all your opta configuration files to migrate to make sure that your infrastructure is current.
2. For each infrastructure stack managed by opta run `generate-terraform` for it using the `--backend remote`. Setting `remote` will ensure that your existing infrastucture state is migrated, so you can use terraform to maintain your existing infrastructure without having to recreate it from scratch.
  ```shell
  # repeat for every environment file (or use the --env variable)
  opta generate-terraform --backend remote -c env-file.yaml

  # repeat for every service
  opta generate-terraform --backend remote -c service-a.yaml
  opta generate-terraform --backend remote -c service-b.yaml
  ```
3. Each `opta generate-terraform `command will generate a new local folder containing the terraform files. Follow the instructions on each readme file on how to use terraform to provision your infrastructure for each stack.
4. We recommend that you save the generated files to your source code management tool (ex: github).

That's it! Now you can use terraform to provision the infrastructure.

If you have more than one environment, use  the `--directory` option with a different value for each environment name.

Note: The service depends on the environment creation, for example a service needs to install itself on a Kubernetes cluster. For this reason, the terraform files for the environment and the service need to be exported in the same output directory. The generated terraform code is already modularized so feel free to reorganize it differently if you would like a different layout.

## Support and limitation

- Clouds: AWS, GCP, Azure are supported.
- Modules: Most opta modules are supported except for a few (ex: DNS, Datadog) where Opta does some processing outside of terraform. 

If your configuration uses a module that is not supported, the command will output a warning listing the unsupported modules. For most cases, there will be additional documentation generated in the readme on how to configure these modules outside of terraform.  If you have already configured these modules (ex: DNS) and migrate your infrastucture from Opta to Terraform, it will still work as expected. 

If you run into an issue or would like extra support, please join our [slack](https://slack.opta.dev/) and reach out to us there.
