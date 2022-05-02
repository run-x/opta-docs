---
title: "GCP"
linkTitle: "GCP"
date: 2022-01-03
weight: 3
description: >
  Getting started with Opta on GCP.
---

To use Opta, you first need to create some simple yaml configuration files that describe your needs. In the following guide we will deploy a simple python flask application.

## 1: Installation

For Opta to work, the prerequisite tools needed are:
- [terraform](https://www.terraform.io/downloads.html) (v0.14+)
- [docker](https://docker.com/products/docker-desktop) (v19+)
- [GCP SDK](https://cloud.google.com/sdk/docs/install) (For GCP only)

Then you can simply install opta using this command ([detailed instructions](/installation)):

```
/bin/bash -c "$(curl -fsSL https://docs.opta.dev/install.sh)"
```

## 2: Environment creation

Before you can deploy your app, you need to first create an environment (like staging, prod etc.)
This will sets up the base infrastructure (like network and cluster) that will be the foundation for your app.

> Note that it costs around $5 per day to run this on GCP So make sure to destroy it after you're done 
> (opta has a destroy command so it should be easy :))!

Create this file and name it `opta.yaml`

```yaml
# opta.yaml
name: staging # name of the environment
org_name: my-org # A unique identifier for your organization
providers:
  google:
    region: us-central1
    project: XXXXX # the name of your GCP project
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
```

Now, run:

```bash
opta apply
```

For the first run, this step takes approximately 15 min.  
It configures 3 Opta modules:
- [base](/reference/google/modules/gcp-base/): setup networking
- [k8s-cluster](/reference/google/modules/gcp-gke/): create a GKE cluster
- [k8s-base](/reference/google/modules/gcp-k8s-base/): setup base infrastructure for k8s

For more information about what is created, see [GCP Architecture](/security/gcp/).

Once done, the `apply` command lists all the resource created, for example:
```tf
# partial output of opta apply

k8s_cluster_name = [The Kubernetes cluster name]
load_balancer_raw_ip = [Load Balancer IP]

Opta updates complete!
```

## 3: Service creation

In this step we will create a service - which is basically a http server packaged in a docker container.  
Here is a simple hello world app, the source code is [here](https://github.com/run-x/hello-opta).


Create a new opta file for your service.
```yaml
# hello.yaml
name: hello
environments:
  - name: staging
    path: "opta.yaml" # the file we created in previous step
modules:
  - type: k8s-service
    name: hello
    port:
      http: 80
    # from https://github.com/run-x/hello-opta
    image: ghcr.io/run-x/hello-opta/hello-opta:main
    healthcheck_path: "/"
    # path on the load balancer to access this service
    public_uri: "/hello"
```

Now you are ready to deploy your service.
```bash
opta apply -c hello.yaml
```

```bash
# partial output of opta apply -c hello.yaml
hello-hello-k8s-service-586447679-fgmld  * Running on http://10.0.147.114:80/
...
module.hello.helm_release.k8s-service: Creation complete after 53s [id=staging-hello]

Opta updates complete!
```

Now, your service is deployed, you can:

- Access your service using the load balancer (public)
```bash
# see output above or run `opta output | grep load_balancer_raw_ip`
export load_balancer_raw_ip=...

# the service is reachable at /hello (set in the `public_uri` property)
curl http://$load_balancer_raw_ip/hello

<p>Hello from Opta.!</p>
```

- SSH into the container
```bash
opta shell -c hello.yaml

root@staging-hello-k8s-service-57d8b6f478-vwzkc:/#
```
- See the application logs 
```bash
opta logs -c hello.yaml             

Showing the logs for server hello-hello-k8s-service-586447679-fgmld of your service
hello-hello-k8s-service-586447679-fgmld  * Running on http://10.0.147.114:80/
hello-hello-k8s-service-586447679-fgmld 127.0.0.1 - - [23/Dec/2021 19:42:18] "GET / HTTP/1.1" 200 -
```
- If you have `kubectl` installed, you can use it to connect to the kubernetes cluster
```bash
# configure the kubeconfig file
# note: if you don't want to use the default path $HOME/.kube/config, set the env var KUBECONFIG first
opta configure-kubectl

# Opta created all the kubernetes resources for your service
kubectl get all --namespace hello

NAME                                            READY   STATUS    RESTARTS   AGE
pod/hello-hello-k8s-service-586447679-fgmld   2/2     Running   0          17m

NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/hello   ClusterIP   172.20.221.139   <none>        80/TCP    17m

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-hello-k8s-service   1/1     1            1           17m

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-hello-k8s-service-586447679   1         1         1       17m

NAME                                                            REFERENCE                              TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hello-hello-k8s-service   Deployment/hello-hello-k8s-service   18%/80%, 1%/80%   1         3         1          17m
```

## 4: Cleanup

Once you're finished playing around with these examples, you may clean up by running the following command from the environment directory:

```bash
# destroy the service resources
opta destroy -c hello.yaml

# destroy the environment resources
opta destroy -c opta.yaml
```

## 5: Next steps

- View the [GCP Architecture](/security/gcp/)
- Check out how to templatize with [variables](/features/variables)
- Check out more examples: [github](https://github.com/run-x/opta/tree/main/examples)
- Use your own docker image: [Custom Image](/features/custom_image/)
- Set up a domain name for your service: [Configure DNS](/features/dns-and-cert/dns/)
- Use secrets: [Secrets](/features/secrets/)
- Set up observability integrations in one line(!): [Observability](/features/observability/)
- Explore all the infrastructure that Opta sets up for you: [Architecture](/security/aws/)
- Explore the api for all modules: [Reference](/reference/google/)
