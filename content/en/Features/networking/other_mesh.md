---
title: "Using Other Service Meshes"
linkTitle: "Using Other Service Meshes"
date: 2022-03-11
weight: 5
draft: false
description: >
  How to use a different service mesh (instead of Linkerd)
---

## Using Other Service Meshes
Opta does not force Linkerd on its users, but merely makes it the default due to its 
[clear merits, and popularity over other service meshes like Istio](https://linkerd.io/2022/02/16/linkerd-istio-adoption/index.html).
An Opta user is free to use alternative service meshes by disabling the Linkerd installation in the `k8s-base` Opta module
of their environment. This is done by adding the `linkerd_enabled: false` as a field like so:

```yaml
name: staging
org_name: my-org
providers:
  aws:
    region: us-east-1
    account_id: XXXX # Your 12 digit AWS account id
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
    linkerd_enabled: false
```

If installing a different service mesh, a user is then responsible to make sure that the services are being configured 
accordingly.
