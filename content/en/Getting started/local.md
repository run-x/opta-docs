---
title: "Local"
linkTitle: "Local"
weight: 4
description: >
  Getting started with Opta Local on your local machine.
---


Opta Local enables you to setup a local Kubernetes environment on your PC using the [Opta CLI](https://docs.opta.dev/overview/) so that you can test services locally without having to pay for cloud resources or waiting for real infrastructure to spin up and down in your cloud provider. It is designed to get you quickly started with Opta and Kubernetes for development and testing without the complexity, cost and learning curve of using a public cloud provider. When you are ready to go to production, the same Opta infrastructure-as-code files you create for Opta Local can be used to deploy to AWS, Azure or Google Cloud.

## Installation

One line installation ([detailed instructions](/installation)):

```bash
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

## Architecture
![Opta Local Architecture](/images/optalocal-arch.png)
This diagram shows what an Opta local installation will look like inside your local machine. Opta Local installs a [Kubernetes Kind cluster](https://kind.sigs.k8s.io/). Kind is a tool for running local Kubernetes clusters using Docker container “nodes”. Kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

Opta Local also installs a local container image registry to store your application images when you use [`opta deploy`](https://docs.opta.dev/tutorials/custom_image/). This docker registry is available at `http://localhost:5000`. 

As a user you can deploy a single Kubernetes Kind cluster on a local machine and then deploy multiple application services (for example, service A and service B) Internally, Kind uses nested containers to run Kubernetes pods inside the Kind container. 

Opta Local also provides platform-as-a-service by creating Postgres or Redis (more PaaS platforms are being integrated, contact us if you would like to see a specific PaaS for your use case). Multiple service platforms of the same type are possible. So for example, Service A and B use isolated PaaS databases in the picture above. Services can be accessed on `http://localhost:8080/` and subpaths. Service A has been configured to be available at `http://localhost:8080/service_A`.

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

#### Example 1: Deploy a service using an existing docker image

We will deploy a simple [hello app](https://github.com/run-x/opta-examples/tree/main/hello-app) by defining these two files.

{{< tabs tabTotal="2" tabID="1" tabName1="hello.yaml" tabName2="local.yaml" >}}
{{< tab tabNum="1" >}}

{{< highlight yaml >}}
# hello.yaml
name: hello
environments:
  - name: local
    path: "local.yaml"
modules:
  - type: k8s-service
    name: hello
    port:
      http: 80
    # from https://github.com/run-x/opta-examples/tree/main/hello-app
    image: ghcr.io/run-x/opta-examples/hello-app:main
    healthcheck_path: "/"
    public_uri: "/hello"

{{< / highlight >}}

{{< /tab >}}

{{< tab tabNum="2" >}}

{{< highlight yaml >}}
# local.yaml
name: local
org_name: my-org
providers: 
  local: {}
modules:
  - type: local-base
{{< / highlight >}}

{{< /tab >}}
{{< /tabs >}}


Create the local kubernetes cluster:
```bash
# estimated time for first run: 10 min
opta apply --local --auto-approve -c local.yaml
...
╒═══════════╤═══════════════════════════════════════╤══════════╤════════╤══════════╕
│ module    │ resource                              │ action   │ risk   │ reason   │
╞═══════════╪═══════════════════════════════════════╪══════════╪════════╪══════════╡
│ localbase │ null_resource.k8s-installer           │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ null_resource.kind-installer          │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ null_resource.local-base              │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ tls_cert_request.issuer_req           │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ tls_locally_signed_cert.issuer_cert   │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ tls_private_key.issuer_key            │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ tls_private_key.trustanchor_key       │ create   │ LOW    │ creation │
├───────────┼───────────────────────────────────────┼──────────┼────────┼──────────┤
│ localbase │ tls_self_signed_cert.trustanchor_cert │ create   │ LOW    │ creation │
╘═══════════╧═══════════════════════════════════════╧══════════╧════════╧══════════╛
...
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

You can verify that the cluster has been created with kind:
```bash
~/.opta/local/kind get clusters

opta-local-cluster
```

Now, let's deploy our service.
```bash
opta apply --local --auto-approve -c hello.yaml

╒══════════╤══════════════════════════╤══════════╤════════╤══════════╕
│ module   │ resource                 │ action   │ risk   │ reason   │
╞══════════╪══════════════════════════╪══════════╪════════╪══════════╡
│ hello    │ helm_release.k8s-service │ create   │ LOW    │ creation │
╘══════════╧══════════════════════════╧══════════╧════════╧══════════╛
...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```


You can test your service by visiting [http://localhost:8080/hello](http://localhost:8080/hello) on your local machine browser.
![Opta Local hello world](/images/hello-world-browser.png)


- SSH into the container
```bash
opta shell -c hello.yaml

root@staging-hello-k8s-service-57d8b6f478-vwzkc:/#
```

- If you have `kubectl` installed, you can use it to connect to the local kubernetes cluster
```bash
# Opta created all the kubernetes resources for your service
kubectl get all --namespace hello
NAME                                           READY   STATUS    RESTARTS   AGE
pod/hello-hello-k8s-service-7b66c95997-xkml6   1/1     Running   0          20m

NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/hello   ClusterIP   10.96.194.3   <none>        80/TCP    84m

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-hello-k8s-service   1/1     1            1           20m

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-hello-k8s-service-7b66c95997   1         1         1       20m

NAME                                                          REFERENCE                            TARGETS                        MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hello-hello-k8s-service   Deployment/hello-hello-k8s-service   <unknown>/80%, <unknown>/80%   1         3         1          84m
```

#### Example 2: Deploy a service using a local docker image

Now, let's build an application locally and deploy it.

For this example, we will use our hello application (also available on [github](https://github.com/run-x/opta-examples/tree/main/hello-app)).
1. Make sure that you have these files locally: 
    - `hello.yaml` The service Opta file. 
    - `local.yaml` The environment Opta file. 
    - `app.py` The application code.
    - `Dockerfile` The docker file to build the application.
1. Set `image: AUTO` in `opta.yaml` to use the local image.
1. Make a change to the returned text in `app.py` to validate that the new image is used.

{{< tabs tabTotal="4" tabID="2" tabName1="opta.yaml" tabName2="local.yaml" tabName3="app.py" tabName4="Dockerfile" >}}
{{< tab tabNum="1" >}}
{{< highlight yaml "hl_lines=11" >}}
# hello.yaml
name: hello
environments:
  - name: local
    path: "local.yaml"
modules:
  - type: k8s-service
    name: hello
    port:
      http: 80
    image: AUTO # 2 Use automatic deployment
    healthcheck_path: "/"
    public_uri: "/hello"
{{< / highlight >}}

{{< /tab >}}

{{< tab tabNum="2" >}}
{{< highlight yaml >}}
# local.yaml
name: local
org_name: my-org
providers: 
  local: {}
modules:
  - type: local-base
{{< / highlight >}}

{{< /tab >}}

{{< tab tabNum="3" >}}
{{< highlight py "hl_lines=5-6" >}}
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello_world():
    #3 Update the returned text
    return "<p>Hello, World! v2</p>"
{{< / highlight >}}
{{< /tab >}}

{{< tab tabNum="4" >}}
{{< highlight dockerfile >}}
FROM python:3.8-slim-buster

ENV FLASK_APP=app

WORKDIR /app

RUN pip install Flask==0.12 
COPY . /app
ENV PORT 80

CMD python3 -m flask run \-\-host=0.0.0.0 \-\-port=${PORT}
{{< / highlight >}}
{{< /tab >}}

{{< /tabs >}}


Apply the local changes:
```
# only needed if not done with previous example, otherwise it will have no effect
opta apply --local --auto-approve -c local.yaml

# to use the AUTO deployment
opta apply --auto-approve -c hello.yaml

...
╒══════════╤══════════════════════════╤══════════╤════════╤══════════════════════════════╕
│ module   │ resource                 │ action   │ risk   │ reason                       │
╞══════════╪══════════════════════════╪══════════╪════════╪══════════════════════════════╡
│ hello    │ helm_release.k8s-service │ update   │ LOW    │ deploying new version of app │
╘══════════╧══════════════════════════╧══════════╧════════╧══════════════════════════════╛
...
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Build the image locally, let's tag it with `v2`:
```bash
docker build . -t hello-app:v2
```


Deploy the new image version to the local kubernetes cluster.  
The `opta deploy` command will:
1. Push the image to the local container registry `localhost:5000`
1. Update the kubernetes deployment to use the new container image.
1. Create new pods to use the new container image - automatically done by kubernetes.

```bash
opta deploy --auto-approve -c hello.yaml --image hello-app:v2
...
The push refers to repository [localhost:5000/hello/hello]
...
╒══════════╤══════════════════════════╤══════════╤════════╤══════════════════════════════╕
│ module   │ resource                 │ action   │ risk   │ reason                       │
╞══════════╪══════════════════════════╪══════════╪════════╪══════════════════════════════╡
│ hello    │ helm_release.k8s-service │ update   │ LOW    │ deploying new version of app │
╘══════════╧══════════════════════════╧══════════╧════════╧══════════════════════════════╛
...
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

docker_repo_url = "localhost:5000/hello/hello"
Opta updates complete!
```

Now let's verify that the deployed application has our local changes:
```
# check the returned text
curl http://localhost:8080/hello
<p>Hello, World! V2</p>%

# check the deployed image uses the local registry
kubectl -n hello get deploy -o yaml | grep image:
          image: localhost:5000/hello/hello@sha256:859eab99a173f975ebe9ba1c54a9fbf4498bf428ae46faa55770cb4272962d7a

```


You can remove this service by running

```bash
opta destroy --auto-approve --local --config hello.yaml
```

#### Example 3: Stateful Example: A Todo list with Prometheus/Grafana
In this example we will deploy a Todo list with a Vuejs single page application frontend, a Django Rest Framework API backend and a Postgres database to store state. Additionally, we will also show how to enable a Prometheus/Grafana observability stack.

Follow [this documentation](https://github.com/run-x/opta-examples/tree/main/full-stack-example) for the full stack Opta example.

## Limitations: What Opta Local is not


1. Only one Kubernetes cluster (a.k.a. Opta environment) is currently allowed on Opta Local.
2. TLS certificates and DNS are not supported.
3. Advanced public cloud features like IAM permissions are not supported.
4. Performance limitations and limited scale.
5. Opta Local runs the latest stable Kubernetes version, currently its not possible to choose which Kubernetes version to install.
6. Opta Local's Kubernetes cluster survives reboots, but it may be several minutes before the services deployed inside it are restored on the newly rebooted host. In general it is not recommended to store valuable information inside the local cluster.
   
All these features are supported in the public cloud. Opta makes it super-convenient to graduate from Opta Local to any of the big-3 public cloud providers (AWS, Azure or GCP).  
Learn more about Opta for public cloud [here](https://docs.opta.dev/getting-started/).


## Uninstallation and Cleanup

If you want to clean out Opta Local from the local machine, run these commands in the terminal

### Uninstall via Opta CLI

First, `opta destroy` all services running inside the local cluster .  
Then once the local Opta Kubernetes Kind cluster is empty you can run:

```bash
opta destroy --auto-approve --local --config local.yaml
```

### Manual Cleanup

```bash
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
