---
title: "Debugging"
linkTitle: "Debugging"
date: 2020-02-01
description: >
  How to debug your app
---

> Ideally, you should set up [observability](/docs/tutorials/observability) so that manual debugging is not needed.

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
(created by opta). This is pretty simple in the opta world! Just run:
```
  opta configure-kubectl
```

### View pods
> Kubernetes uses the word "pod" for containers[^1]. So every service will have one or more pods (as specified in your opta yml).

You can see the pods for a given service by running:
```
kubectl get pods -n <service-name>
```
>If this doesn't show any pods, that means your service hasn't been deployed. Check out the [deployment docs](/docs/getting-started/#service-deployment) to fix that.

Note that `<service-name>` is specified in your opta yml:
```
  meta:
    name: blah # service-name
  modules:
    app: # module-name
      type: k8s-service
```


### View logs for a pod
Note down the name of one of your pods and then run the following command to see it's logs:
```
kubectl logs -f <pod-name> k8s-service -n <service-name>
```

To view logs from *all* your pods, you can run:
```
kubectl logs -f deployments/<service-name>-<module-name>-k8s-service k8s-service -n <service-name>
```

### SSH into a pod
Note down the name of one of your pods and then run the following command to ssh into it:
```
kubectl exec -it <pod-name> -n <service-name> -- bash
```


[^1]: [Detailed pods docs](https://kubernetes.io/docs/concepts/workloads/pods/)
