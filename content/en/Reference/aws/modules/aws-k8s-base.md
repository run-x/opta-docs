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
| `nginx_extra_tcp_ports` | Additional TCP ports to expose from nginx | `[]` | False |
| `nginx_extra_tcp_ports_tls` | Which additional TCP ports should have TLS enabled | `[]` | False |
| `expose_self_signed_ssl` | Expose self-signed SSL certs. | `False` | False |
| `cert_manager_values` | Certificate Manager helm chart additional values. [Available options](https://artifacthub.io/packages/helm/cert-manager/cert-manager?modal=values) | `{}` | False |
| `linkerd_values` | Linkerd helm chart additional values. [Available options](https://artifacthub.io/packages/helm/linkerd2/linkerd2/2.10.2?modal=values) | `{}` | False |
| `ingress_nginx_values` | Ingress Nginx helm chart additional values. [Available options](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx/4.0.17?modal=values) | `{}` | False |
| `domain` | Domain to setup the ingress with. By default uses the one specified in the DNS module if the module is found. | `` | False |
| `zone_id` | ID of Route53 hosted zone to add a record for. By default uses the one created by the DNS module if the module is found. | `` | False |
| `cert_arn` | The arn of the ACM certificate to use for SSL. By default uses the one created by the DNS module if the module is found and delegation enabled. | `` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `load_balancer_raw_dns` | The dns of the network load balancer provisioned to handle ingress to your environment |
| `load_balancer_arn` | The arn of the network load balancer provisioned to handle ingress to your environment |