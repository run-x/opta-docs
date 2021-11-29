---
title: "Installation"
linkTitle: "Installation"
weight: 3
---

## Prerequisites

Opta currently has the following system prerequisites to operate normally:

- A supported macos or debian distro release.
- [terraform](https://www.terraform.io/downloads.html) (v0.14+)
- [docker](https://docker.com/products/docker-desktop) (v19+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (also packaged with
  docker-for-mac)
- [GCP SDK](https://cloud.google.com/sdk/docs/install) (For GCP only)
- [Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (For Azure only)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) (v2) (For AWS only)
- Opta assumes that git, curl and unzip tools are already installed on the command line; in addition if you are using Ubuntu/Debian Linux then the `language-pack-en` package should be installed; you may also need to add `export LC_CTYPE=en_US.UTF-8` to your profile. 

## MacOS or Linux

Run this script to install the latest version of Opta (see below for changelog
and release history).

```bash
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

You can specify a particular version as well.

```bash
VERSION=0.x /bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

## Releases

[Github](https://github.com/run-x/opta/releases)


## GCP Authentication
To make sure the gcp cloud credentials are configured in your terminal. 
1. Create a [Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating) for your project. Make sure the Service Account has the following roles assigned
    - CA Service Certificate Manager
    - Cloud KMS Admin
    - Compute Network Admin
    - Kubernetes Engine Admin
    - Project IAM Admin
    - Secret Manager Secret Accessor
3. Once the Service Account is created, [create and download a Service Account Key JSON file](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
4. Since opta can run outside of the GCP environment, be sure to set the GCP credentials environment variable:
```shell
$ export GOOGLE_APPLICATION_CREDENTIALS="/path/to/keyfile.json"
```
