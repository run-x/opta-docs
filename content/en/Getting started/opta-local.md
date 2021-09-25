# Opta Local

Opta Local enables you to setup a local Kubernetes environment on your PC using the [Opta CLI](https://docs.opta.dev/overview/) so that you can locally test services without having to pay for cloud resources or waiting for real infrastructure to spin up and down in your cloud provider. 


## Architecture

Fig. 1 shows what an Opta local installation will look like inside your local machine. Opta Local installs a [Kubernetes Kind cluster](https://kind.sigs.k8s.io/)Kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

Opta Local also installs a local container image registry to store your application images when you use [`opta deploy`](https://docs.opta.dev/tutorials/custom_image/). This docker registry is available at `http://localhost:5000`. 
As a user you can deploy a single Kubernetes kind cluster on a local machine and then deploy multiple application services (for example, service A and service B in Fig. 1) Internally, Kind uses nested containers to run Kubernetes pods inside the Kind container. As such, this is suitable for functional testing but not for high-performance use cases such as load testing your application.

Opta Local also provides platform-as-a-service by creating Postgres or Redis (more PaaS platforms are being integrated, send us an email if you would like to see a specific PaaS). Multiple service platforms of the same type are possible. So for example, Service A and B use isolated PaaS databases in Fig. 1. Services can be accessed on `http://localhost:8080/`. Service A in Fig.1 has been configured to be available at `http://localhost:8080/service_A`.

## System Requirements

  1. A Mac OS or Linux PC with a minimum 8GB RAM and a recent i5 processor.
  2. Fast internet connection
  3. Ample diskspace (at least 10GB free) to store container images locally
  4. Please install the prerequistes for opta [listed here](https://docs.opta.dev/installation/#prerequisites). You can exclude the public cloud specific pre-requisites if you only want to run Opta Local for now.
  5. Opta Local assumes that the logged-in user can operate docker without sudo; to enable this follow the steps here: [MacOS](https://docs.docker.com/desktop/mac/install/) or [Linux](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) )

## Getting Started

There are two steps in getting Opta Local running. First, we create a Kubernetes Kind and local docker registry installation going on your local machine. Second, we create services inside the Kubernetes installation. 

### Kubernetes Environment on Local Machine

Create a local environment opta yaml file called `local-opta-env.yaml`. Here is an example:

```yaml
name: localkindk8s
org_name: laptop
providers: 
  local: {}
modules:
  - type: local-base

```

Then run opta on this file
```bash
opta apply --detailed-plan --config local-opta-env.yaml 
```

After a few minutes, you should see Opta complete. You should see outputs like so

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

k8s_cluster_name = "kind-opta-local-cluster"
INFO: Opta updates complete!
```

Next, lets look at what docker containers are installed on the local machine.

```
# Terminal command
docker ps

# Output
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                                                    NAMES
bd449dba1c4e   kindest/node:v1.21.1   "/usr/local/bin/entr…"   51 seconds ago   Up 50 seconds   0.0.0.0:8080->80/tcp, 0.0.0.0:6443->443/tcp, 127.0.0.1:40049->6443/tcp   opta-local-cluster-control-plane
6177c61e6818   registry:2             "/entrypoint.sh /etc…"   52 seconds ago   Up 51 seconds   127.0.0.1:5000->5000/tcp                                                 opta-local-registry
```

Finally, verify that Kubernetes Kind is running

```
# Terminal command
kubectl get no

# Output
NAME                               STATUS   ROLES                  AGE   VERSION
opta-local-cluster-control-plane   Ready    control-plane,master   76s   v1.21.1

# Terminal command
kubectl cluster-info

# Output
Kubernetes master is running at https://127.0.0.1:40049
CoreDNS is running at https://127.0.0.1:40049/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy


This Kubernetes cluster will survive reboots of the local machine.

```

### Services 

Running services in Opta Local environment is almost identical to how you would run them on public cloud using the Opta CLI. We show a couple of opta yaml examples to get you started.

**Example 1:** A simple [Httpbin](https://github.com/postmanlabs/httpbin) deployment. Save this yaml snippet in `httpbin.yaml`:

```yaml
name: httpbinapp
environments:
  - name: localkindk8s
    path: "local-opta-env.yaml"
modules:
  - name: statelessapp
    type: k8s-service
    port:
      http: 80
    image: docker.io/kennethreitz/httpbin:latest
    healthcheck_path: "/get"
    public_uri: "/"

```

Adjust the path of the environment file `local-opta-env.yaml` as needed. The run 

```bash
# Terminal command
opta apply --detailed-plan --config httpbin.yaml 

# Output
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

docker_repo_url = ""
INFO: Opta updates complete!


```

You can test your service by visiting `http://localhost:8080/` on your local machine browser. You should see an output like so:

h


## Limitations: What Opta Local is not

1. Only one Kubernetes cluster (a.k.a. Opta environment) is currently allowed on Opta Local.
2. TLS certificates and DNS are not supported.
3. Advanced public cloud features like IAM permissions are not supported.
4. Performance limitations and limited scale.
5. Opta Local runs the latest stable Kubernetes version, currently its not possible to choose which Kubernetes version to install.

All these features are supported in the public cloud. Opta makes it super-convenient to graduate from Opta Local to any of the big-3 public cloud providers (AWS, Azure or GCP). Learn more about Opta here.

## Troubleshooting
1. 