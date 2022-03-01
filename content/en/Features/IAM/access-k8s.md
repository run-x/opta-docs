---
title: "Kubernetes Access"
linkTitle: "Kubernetes Access"
date: 2021-07-21
description: >
  How to connect to Kubernetes
---

### Configure kubectl

Before you can use `kubectl`, you need to connect it to your kubernetes cluster
(created by opta). This is pretty simple in the Opta world! Just run:

```bash
opta configure-kubectl
```

> By defaut opta use the default kube config file `~/.kube/config`, if you want to use a different file set the `KUBECONFIG` environment variable.
