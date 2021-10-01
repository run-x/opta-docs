---
title: "k8s-base"
linkTitle: "k8s-base"
date: 2021-07-21
draft: false
weight: 1
description: Creates base infrastructure for k8s environments
---

### Features

This module is responsible for all the base infrastructure we package into the Opta K8s environments. This includes:

- [Autoscaler](https://github.com/kubernetes/autoscaler) for scaling up and down the ec2s as needed
- [External DNS](https://github.com/kubernetes-sigs/external-dns) to automatically hook up the ingress to the hosted zone and its domain
- [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
- [Metrics server](https://github.com/kubernetes-sigs/metrics-server) for scaling different deployments based on cpu/memory usage
- [Linkerd](https://linkerd.io/) as our service mesh.
- [Cert Manager](https://cert-manager.io/docs/) for internal ssl.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `nginx_high_availability` | Deploy the nginx ingress in a high-availability configuration. | `False` | False |
| `linkerd_high_availability` | Deploy the linkerd service mesh in a high-availability configuration for its control plane. | `False` | False |
| `linkerd_enabled` | Enable the linkerd service mesh installation. | `True` | False |
| `admin_arns` | ARNs for users/roles who should be K8s admins. The user running Opta is by default an admin. | `[]` | False |
| `nginx_config` | Additional configuration for nginx ingress. [Available options](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#configuration-options) | `{}` | False |