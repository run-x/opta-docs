---
title: "Local"
linkTitle: "Local"
weight: 4
description: >
  Getting started with Opta Local on your local machine.
---


Opta Local enables you to setup a local Kubernetes environment on your PC using the [Opta CLI](https://docs.opta.dev/overview/) so that you can test services locally without having to pay for cloud resources or waiting for real infrastructure to spin up and down in your cloud provider. It is designed to get you quickly started with Opta and Kubernetes for development and testing without  the complexity, cost and learning curve of using a public cloud provider. When you are ready to go to production, the same Opta infrastructure-as-code files you create for Opta Local can be used to deploy to AWS, Azure or Google Cloud.


## Architecture
![Opta Local Architecture](/images/optalocal-arch.png)
Fig. 1 shows what an Opta local installation will look like inside your local machine. Opta Local installs a [Kubernetes Kind cluster](https://kind.sigs.k8s.io/). Kind is a tool for running local Kubernetes clusters using Docker container “nodes”. Kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

Opta Local also installs a local container image registry to store your application images when you use [`opta deploy`](https://docs.opta.dev/tutorials/custom_image/). This docker registry is available at `http://localhost:5000`. 

As a user you can deploy a single Kubernetes Kind cluster on a local machine and then deploy multiple application services (for example, service A and service B in Fig. 1) Internally, Kind uses nested containers to run Kubernetes pods inside the Kind container. 

Opta Local also provides platform-as-a-service by creating Postgres or Redis (more PaaS platforms are being integrated, contact us if you would like to see a specific PaaS for your use case). Multiple service platforms of the same type are possible. So for example, Service A and B use isolated PaaS databases in Fig. 1. Services can be accessed on `http://localhost:8080/` and subpaths. Service A in Fig.1 has been configured to be available at `http://localhost:8080/service_A`.

## System Requirements

Running Opta Local needs a reasonably powerful PC. These requirements are not for running Opta itself, but for spinning up Kubernetes and running your services on it.

  1. A Mac OS or Linux PC with a minimum 8GB RAM and a recent i5 processor.
  2. Fast internet connection
  3. Ample diskspace (at least 10GB free) to store container images locally
  4. Please install the prerequistes for opta [listed here](https://docs.opta.dev/installation/#prerequisites). You can exclude the public cloud specific pre-requisites if you only want to run Opta Local.
  5. Opta Local assumes that the logged-in user can operate docker without sudo; to enable this follow the steps here: [MacOS](https://docs.docker.com/desktop/mac/install/) or [Linux](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) ).
  6. Opta Local requires local ports `5000` and `8080` to be free for use in order to function.

## Getting Started

There are two steps in getting Opta Local running. First, Opta will create a Kubernetes Kind cluster and local docker registry installation on your local machine for you. Second, we create services inside the Kubernetes installation.


### Services 

Running services in Opta Local environment is almost identical to how you would run them on public cloud using the Opta CLI. We show a couple of opta yaml examples to get you started.

#### Example 1: Stateless Service

We deploy a simple [Httpbin](https://github.com/postmanlabs/httpbin) deployment.

Save this yaml snippet in `httpbin.yml`:

```yaml
name: httpbinapp
environments:
  - name: aws
    path: "aws.env"
modules:
  - name: statelessapp
    type: k8s-service
    port:
      http: 80
    image: docker.io/kennethreitz/httpbin:latest
    healthcheck_path: "/get"
    public_uri: "/"

```
Note we set the environment to "aws", a public cloud provider, so this service infrastructure-as-code file is ready to be deployed on AWS. But we will pass the `--local` flag when calling the Opta to have it instead deploy to the local Kubernetes installation.

```bash
# Terminal command
opta apply --local --config httpbin.yml 

# Output
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

docker_repo_url = ""
INFO: Opta updates complete!


```

You can test your service by visiting `http://localhost:8080/` on your local machine browser. You should see an output like so:

![Opta Local httpbin](/images/httpbin.png)

You can remove this service by running

```bash
opta destroy --local --config httpbin.yml
```

#### Example 2: Stateful Example: A Todo list with Prometheus/Grafana
In this example we will deploy a Todo list with a Vuejs single page application frontend, a Django Rest Framework API backend and a Postgres database to store state. Additionally, we will also show how to enable a Prometheus/Grafana observability stack.

Follow [this documentation](https://github.com/run-x/opta-examples/tree/main/full-stack-example) for the full stack Opta example.

## Limitations: What Opta Local is not


1. Only one Kubernetes cluster (a.k.a. Opta environment) is currently allowed on Opta Local.
2. TLS certificates and DNS are not supported.
3. Advanced public cloud features like IAM permissions are not supported.
4. Performance limitations and limited scale.
5. Opta Local runs the latest stable Kubernetes version, currently its not possible to choose which Kubernetes version to install.
6. Opta Local's Kubernetes cluster survives reboots, but it may be several minutes before the services deployed inside it are restored on the newly rebooted host. In general it is not recommended to store valuable information inside the local cluster.
   
All these features are supported in the public cloud. Opta makes it super-convenient to graduate from Opta Local to any of the big-3 public cloud providers (AWS, Azure or GCP). Learn more about Opta for public cloud [here](https://docs.opta.dev/getting-started/).


## Uninstallation and Cleanup

If you want to clean out Opta Local from the local machine, run these commands in the terminal

### Uninstall via Opta CLI

First, `opta destroy` all services running inside the local cluster . Then once the local Opta Kubernetes Kind cluster is empty you can run

```bash
opta destroy ~/.opta/local/localopta.yml --auto-approve

```
### Manual Cleanup

DOCKER_REGISTRY=`docker ps -aqf "name=opta-local-registry"`
docker stop $DOCKER_REGISTRY
docker rm $DOCKER_REGISTRY
~/.opta/local/kind delete clusters opta-local-cluster
rm -rf ~/.opta/local

```

Running these commands should remove the Kind Kubernetes docker container (along with everything installed in Kubernetes) as well as the local docker registry container. You can confirm this via the `docker ps` command. 

In case you want to manually remove the Kubernetes Kind container run

```bash
KCLUSTER=`docker ps -aqf "name=opta-local-cluster-control-plane"`
docker stop $KCLUSTER
docker rm $KCLUSTER
```

You can confirm that the docker containers named `opta-local-cluster-control-plane` and `opta-local-registry` have been removed by issuing the `docker ps` command.
