---
title: "k8s-base"
linkTitle: "k8s-base"
date: 2021-07-21
draft: false
weight: 1
description: Creates base infrastructure that is packaged into Opta environments
---

This module is responsible for all the base infrastructure we package into the Opta K8s environments. This includes:

- [Ingress Nginx](https://github.com/kubernetes/ingress-nginx) to expose services to the public
- [Linkerd](https://linkerd.io/) as our service mesh.
- [Cert Manager](https://cert-manager.io/docs/) for internal ssl.
- A custom load balancer and dns routing built to handle the Ingress Nginx which we set up.

## Fields

- `nginx_high_availability` - Optional. Deploy the nginx ingress in a high-availability configuration. Default False
- `linkerd_high_availability` - Optional. Deploy the linkerd service mesh in a high-availability configuration for its control plane. Default False
- `linkerd_enabled` - Optional. Enable the linkerd service mesh installation. Default True
- `nginx_config` - Optional. Additional configuration for nginx ingress. [Available options](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#configuration-options) Default {}

## Outputs

- load_balancer_raw_ip - str