---
title: "Kubectl Configuration"
linkTitle: "Kubectl"
date: 2020-02-01
description: >
  How to configure kubectl for your Opta Kubernetes Cluster
---

You can run the following command to configure kubectl to talk to a kubernetes cluster for a particular environment.
You need to have kubectl installed for this to work.

Note: The following commands needs to be run from the directory where your app's `opta.yml` is present
```bash
opta configure-kubectl --env staging
```

Each service gets created in it's own kubernetes namespace.
You can use `kubctl get namespaces` to list all the namespaces. The name of the namespace for a given service should be the same as the name of the service.
