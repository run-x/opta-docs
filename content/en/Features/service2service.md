---
title: "Service Networking"
linkTitle: "Service Networking"
date: 2022-01-03
draft: false
description: >
  Networking aspects for services
---

## Overview
One of the main subjects Opta answers for its users is service networking -- how services talk to one another
and the external communication. Opta achieves this by utilizing a service mesh, kubernetes ingress, and kubernetes
service discovery, as detailed below.

## Service Mesh
All inter-service communication is handled by the [Linkerd](https://linkerd.io/) service mesh, which Opta installs by default.
Linkerd provides out-of-the-box mTLS, load balancing, retries and many other 
[reliability/security/qos features](https://linkerd.io/2.11/features/). Opta's `k8s-service` modules are designed to
seamlessly assimilate into the installed service mesh. Combined with Linkerd's official principles of 
[keep it simple, minimize resource requirements and just work](https://linkerd.io/design-principles/#), this means that
most development should not even notice the presence of Linkerd and upkeep should be nigh non-existent.

### Linkerd Viz
For monitoring, Linkerd comes with an optional dashboard solution known as [Linkerd Viz](https://linkerd.io/2.11/features/dashboard/).
It is not installed by default due to the non-negligible resource requirement (it installs Prometheus and Grafana
as well as a few smaller tools), but can be easily added with the following commands: 

```shell
curl -fsL https://run.linkerd.io/install | sh   # Install linkerd CLI
linkerd viz install | kubectl apply -f -        # Install linkerd monitoring stack
linkerd viz dashboard                           # open the dashboard
```

### Service Discovery
Every service also gets an internal-only domain name that can be used by other
services to connect to it. The name is `<module-name>.<service-name>`. Requests
sent to this domain will automatically get load balanced b/w all healthy
containers.

For example, the following service, will be available at `app.hello-world` from any other service in the same environment.

{{< highlight yaml "hl_lines=1 7" >}}
name: hello # service name
environments:
- name: staging
  path: "opta.yaml"
  modules:
- type: k8s-service
  name: app # module name
  port:
  http: 80
  image: ghcr.io/run-x/hello-opta/hello-opta:main
  {{< / highlight >}}

### Using Other Service Meshes
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

## External Communication
Opta creates a private subnet where all the services run. So every service is inaccessible from the outside, by default. 
To handle external communication, Opta installs the [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) ingress
solution. This ingress solution and Opta will create a single cloud (e.g. AWS, GCP, Azure) load balancer to handle
incoming traffic to your environment. Opta's `k8s-service` modules are designed to integrate with this default ingress,
and users can enable external requests by using the `public_uri` [field](/reference/aws/service_modules/aws-k8s-service).
