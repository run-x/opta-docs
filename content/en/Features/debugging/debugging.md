---
title: "Debug Running Pods"
linkTitle: "Debug Running Pods"
date: 2022-01-03
weight: 1
description: >
  How to debug your pods
---

> Ideally, you should set up [observability](features/observability) so that manual debugging is not needed.

Opta provides 2 helpful commands to help with debugging:

### View logs

```bash
opta logs -c hello.yaml
```

This will show you logs from all the running container for this service.

### SSH into an instance

```bash
opta shell -c hello.yaml
```

This will open up a shell into one of the running container.

### Kubectl

Opta uses kubernetes under the hood, so we recommend using the standard
kubernetes tool `kubectl` for most debugging use cases. This page will give you
a brief tutorial on how to use this tool.

### Install kubectl

On mac, you can install it via:

```bash
brew install kubectl
```

More detailed instructions are available on the [offical site](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Configure kubectl

Before you can use `kubectl`, you need to connect it to your kubernetes cluster
(created by opta). This is pretty simple in the Opta world! Just run:

```bash
opta configure-kubectl
```

> By defaut opta use the default kube config file `~/.kube/config`, if you want to use a different file set the `KUBECONFIG` environment variable.

### View pods

> Kubernetes uses the word "pod" for containers[^1]. So every service will have one or more pods (as specified in your Opta yml as `min_containers` and `max_containers`).

You can see the pods for a given service by running:

```bash
kubectl get pods -n <service-name>
```

> If this doesn't show any pods, that means your service hasn't been deployed. Check out the [deployment docs](/getting-started/#service-deployment) to fix that.

Note that `<service-name>` is specified in your yaml file:

```yaml
modules:
  - name: hello # service-name
    type: k8s-service
    image: docker.io/kennethreitz/httpbin:latest
```

### Debug logging

Opta supports a verbose debug state wherein the log level is set to debug, and the auto-generated terraform files and
directories are preserved after execution. This configuration serves for troubleshooting errors in deployment and
preserving the full terraform infrastructure as code for the archives or other reasons. To enable this state, simply
set the `OPTA_DEBUG` environment variables to some value like so:

```shell
export OPTA_DEBUG=1
```
