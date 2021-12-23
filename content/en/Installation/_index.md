---
title: "Installation and Upgrade"
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

Run this script to install or upgrade to the latest version of Opta (see below for changelog
and release history).

```bash
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

You can specify a particular version as well.

```bash
VERSION=0.x /bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

## Run Opta in a Docker Container via opta.sh script (Pre-release)

We are now offering a pre-release version for running opta via a docker container with alpha support. __Please do not use this for production workloads currently.__

If you prefer to install or upgrade Opta and its dependencies (terraform, kubectl, gcp sdk, aws cli) in a docker container then you can 
download the `opta.sh` script that runs Opta inside a docker container. With this approach you can be assured that the correct
versions of all of Opta's dependencies are invoked when run.

```bash
# Download the script and add it as an executable on your machine
sudo curl  https://docs.opta.dev/opta.sh -o /usr/local/bin/opta.sh
sudo chmod +x /usr/local/bin/opta.sh
opta.sh # This first invocation builds a docker image
```

Invoke opta using opta.sh instead; for example

```bash
opta.sh apply -c mycode/foo.yaml

```

Any environment variables needed by opta can be set in the terminal invoking `opta.sh`; they will be automatically transferred into the docker container running opta.

Your home directory ($HOME) will be mounted into the `opta.sh` docker container as well.

### Caveats of opta.sh
  1. This script assumes you are logged in as a user that has docker permissions; this is the default when [docker desktop](https://docs.docker.com/desktop/mac/install/) is installed on Mac; for [Linux](https://docs.docker.com/engine/install/linux-postinstall/) see this documentation. 
  2. This script will not work for the newest Mac OS devices with the M1 processor; it should work on Intel-based Mac computers.
  3. This script assumes that your opta yaml files are contained within your `home` directory (Run `echo $HOME` to ascertain this is the case)
   

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
