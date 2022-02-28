---
title: "k8s-base"
linkTitle: "k8s-base"
date: 2021-07-21
draft: false
weight: 1
description: Creates base infrastructure for k8s environments
---

This module is responsible for all the base infrastructure we package into the Opta K8s environments. This includes:

- [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
- [Linkerd](https://linkerd.io/) as our service mesh.
- [Cert Manager](https://cert-manager.io/docs/) for internal ssl
- A custom load balancer and dns routing built to handle the Ingress Nginx which we set up.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `nginx_high_availability` | Deploy the nginx ingress in a high-availability configuration. | `False` | False |
| `linkerd_high_availability` | Deploy the linkerd service mesh in a high-availability configuration for its control plane. | `False` | False |
| `linkerd_enabled` | Enable the linkerd service mesh installation. | `True` | False |
| `nginx_config` | Additional configuration for nginx ingress. [Available options](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#configuration-options) | `{}` | False |
| `expose_self_signed_ssl` | Expose self-signed SSL certs | `False` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `load_balancer_raw_ip` | str |