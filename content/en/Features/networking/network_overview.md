---
title: "Network Overview"
linkTitle: "Network Overview"
date: 2022-03-11
weight: 1
draft: false
description: >
  Service mesh, Service Discovery and Lifecyle of a HTTPS request
---

## Overview

Opta provides a pre-configured network architecture following best practices.

The main features are:
- Service mesh using Linkerd and Nginx for the ingress controller. This provides many networking features including Automatic mTLS and service discovery.
- Load Balancing.
- High availability to provide resiliency in case of zone outages
- Auto-scaling to only use what you need and to enable scalability.
- Public and private subnets to ensure isolation.
- Pre-configured firewall rules for increased security.

## Kubernetes service networking

One of the main subjects Opta answers for its users is Kubernetes service networking -- how services are exposed to the outside and talk to one another. Opta achieves this by utilizing a service mesh, kubernetes ingress, and kubernetes
service discovery.

<a href="/images/network_ingress_overview.png" target="_blank">
  <img src="/images/network_ingress_overview.png" align="center"/>
</a>

- **Load Balancer** (AWS Network LB, GCP External LB):
    - distribute the traffic across multiple servers.
    - do TLS termination for the public certificate - the certificate tied to the public DNS for the service.
- **Ingress Controller** (Nginx):
    - distribute the traffic in the Kubernetes cluster.
- **Linkerd control plane**
    - look up where to send requests.
    - handle retries and timeouts.
    - enable mutually-authenticated Transport Layer Security (mTLS) for all TCP traffic between meshed pods (see [details](https://linkerd.io/2.11/features/automatic-mtls/)).
- **Linkerd proxy**: ultralight transparent micro-proxy attached to every pod.
    - handle all incoming and outgoing TCP traffic to/from that pod.


## Service Mesh

All inter-service communication is handled by the [Linkerd](https://linkerd.io/) service mesh, which Opta installs by default.
Linkerd provides out-of-the-box mTLS, load balancing, retries and many other 
[reliability/security/qos features](https://linkerd.io/2.11/features/). Opta's `k8s-service` modules are designed to
seamlessly assimilate into the installed service mesh. Combined with Linkerd's official principles of 
[keep it simple, minimize resource requirements and just work](https://linkerd.io/design-principles/#), this means that
most development should not even notice the presence of Linkerd and upkeep should be nigh non-existent.

## Service Discovery

Every service also gets an internal-only domain name that can be used by other
services to connect to it. The name is `<service-name>.<layer-name>`. Requests
sent to this domain will automatically get load balanced b/w all healthy
containers.

For example, the *engine* service in the diagram below, will be available at `engine.back` from any other service in the same environment.

<a href="/images/network_service_to_service.png" target="_blank">
  <img src="/images/network_service_to_service.png" align="center"/>
</a>

{{< highlight yaml "hl_lines=1 7" >}}
name: back # layer name
environments:
- name: staging
  path: "opta.yaml"
  modules:
- type: k8s-service
  name: back # k8 service name
  port:
  http: 80
  image: ghcr.io/run-x/hello-opta/hello-opta:main
  {{< / highlight >}}

## Lifecyle of a HTTPS request

This section presents the high level components by following the route of a HTTPS request for a API service. To illustrate the different types of network connections, this example has two services and two databases: one private and one public.

<a href="/images/life_of_a_https_request.png" target="_blank">
  <img src="/images/life_of_a_https_request.png" align="center"/>
</a>


**1 - A client sends a request such as [https://mycompany.com/api/list-objects](https://mycompany.com/api/list-objects)**

- The DNS is publicly resolved to point to one of the public IPs of the load balancer.
- The load balancer serves the public TLS certificate for [mycompany.com](http://mycompany.com) and as such is able to decrypt the HTTPS. The TLS termination is done at this level.
- The load balancer can scale its capacity to adjust to the load.

**2 - The load balancer forwards the https request to an Nginx proxy in the Kubernetes cluster.**

- The load balancer has multiple registered target of Nginx, typically one in each availability zone.
- Nginx listens on HTTPS port (443) using a self signed certificate.
- Opta supports 2 modes for nginx controller: default (1 pod) and [high-availability](/features/networking/high_availability/) (3 pods - one in each availability zone)

**3 - The ingress controller forwards the request to a pod running the api container.**

- The ingress controller uses the ingress rules to know which Kubernetes service should be matched with the url. Ex:  [/api/list-objects](https://mycompany.com/api/list-objects) is for api-service. The ingress rule is set using the `public_uri` [field](/reference/aws/service_modules/aws-k8s-service).
- Linkerd enables mutually-authenticated Transport Layer Security (mTLS) for all TCP traffic between meshed pods.
- The number of pods for a given service is managed by an auto-scaler.

**4 - The api-service pod sends a gRPC request to a data-service pod**

- The service uses the internal service name for the hostname. The routing is done by Linkerd Control Plane service discovery feature.
- Linkerd can route gRPC and HTTPS, all using TLS.
- The number of pods for a given service is managed by an auto-scaler.

**5 - The data-service pod sends a query to a privately hosted database**

- The service uses the fully qualified name to connect to the DB.
- For outside connection, the service mesh proxy is not used.
- For AWS, TLS is always used with RDS. For GCP, TLS is not used by default.
- Cloud databases are organized in a cluster and can scale accordingly.
- This connection stays within the private subnets.
- The stored data is encrypted using the key using the KMS/Vault cloud service.

**6 - The data-service pod sends a query to a public hosted database**

- A Kubernetes pod is never exposed on the internet but can reach the internet through a NAT gateway.
- For outside connection, the service mesh proxy is not used.
- Multi-cloud databases such as MongoDB Atlas Atlas require TLS connection.

**7 - The network address translation (NAT) gateway connects the public database**

- Each NAT is attached to a fixed IP. We recommend to configure a firewall rule using this IP on the destination to restrict the incoming traffic.

From then, the api-service can return the HTTPS response with the api result.
