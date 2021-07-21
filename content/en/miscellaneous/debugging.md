---
title: "Debugging"
linkTitle: "Debugging"
date: 2021-07-21
description: >
  How to debug your app
---

> Ideally, you should set up [observability](/observability) so that manual debugging is not needed.

Opta provides 2 helpful commands to help with debugging:

### View logs

```
opta logs
```

This will show you logs from all your app instances.

### SSH into an instance

```
opta shell
```

This will open up a shell into one of your app instances.

### Kubectl

Opta uses kubernetes under the hood, so we recommend using the standard
kubernetes tool `kubectl` for most debugging use cases. This page will give you
a brief tutorial on how to use this tool.

### Install kubectl

On mac, you can install it via:

```
brew install kubectl
```

More detailed instructions are available on the [offical site](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Configure kubectl

Before you can use `kubectl`, you need to connect it to your kubernetes cluster
(created by opta). This is pretty simple in the Opta world! Just run:

```
  Opta configure-kubectl
```

### View pods

> Kubernetes uses the word "pod" for containers[^1]. So every service will have one or more pods (as specified in your Opta yml).

You can see the pods for a given service by running:

```
kubectl get pods -n <service-name>
```

> If this doesn't show any pods, that means your service hasn't been deployed. Check out the [deployment docs](/getting-started/#service-deployment) to fix that.

Note that `<service-name>` is specified in your Opta yml:

```
  meta:
    name: blah # service-name
  modules:
    app: # module-name
      type: k8s-service
```

### Debug logging

Opta supports a verbose debug state wherein the log level is set to debug, and the auto-generated terraform files and
directories are preserved after execution. This configuration serves for troubleshooting errors in deployment and
preserving the full terraform infrastructure as code for the archives or other reasons. To enable this state, simply
set the `OPTA_DEBUG` environment variables to some value like so:

```shell
export OPTA_DEBUG=1
```
