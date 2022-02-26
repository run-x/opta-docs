---
title: "Securely Accessing Opta Networks Locally"
linkTitle: "Securely Accessing Opta Networks Locally"
date: 2022-01-03
draft: false
weight: 3
description: >
  Instructions to securely access network endpoints in an Opta environment
---

# Overview
When working with secure private networks, and specifically with the databases in them, one may wish to somehow manually 
connect to them for debugging purpose. This action, naturally, has security concerns and there's many 
solutions out there. For our users, we typically recommend installing VPN servers within your opta-managed VPCs and 
handling network access to your environments from there. For just getting started and development environments, however, 
there's a rather straight-forward TCP proxy solution. This article will discuss both solutions and the security concerns.

# TCP-Proxy Service
A quick way to gain connectivity is to create a TCP-Proxy service with opta and using `kubectl port-forward` to gain
access to the proxy locally. Basically, there is this [docker image called tecnativa/tcp-proxy](https://hub.docker.com/r/tecnativa/tcp-proxy)
and it pretty much does what its name says: based on environment variables specified by the user, it forwards all tcp
traffic sent to it on a user-specified port to another user-specified host + port. The way that you can leverage this
with opta is by creating a new k8s-service with Opta using that image, and forwarding TCP connections to your database.

So suppose you have a postgres database (so port 5432, for redis it would be 6379, for mysql 3306 etc...) and its host 
is 10.40.153.14 (you can find out by checking the envars in a linked service). If you wanted to connect to it locally,
you could do so by first creating a following service in your opta environment:
```yaml
environments:
  - name: my-env-yaml
    path: "opta.yaml"
name: mytcpproxy
modules:
  - name: app
    type: k8s-service
    image: tecnativa/tcp-proxy
    min_containers: 1
    max_containers: 1
    port:
      tcp: 5432
    env_vars:
      TALK: "10.40.153.14:5432"
      LISTEN: ":5432"
```

After that service is created you can do a port forward to your localhost with the kubectl port-forward command:

```kubectl port-forward -n mytcpproxy svc/app 5432:80```

While this command is running, all TCP traffic to localhost:5432 shall be passed on to the tcp-proxy container in your
cluster, which will then proxy it to your database. Simply leave this command running, and start debugging in a new
shell.

# VPN Solution

[VPNs](https://en.wikipedia.org/wiki/Virtual_private_network) have been the de-facto private networking solution in the
industry for over a decade. Starting usage is quite simple: the vpn server has a list of users that are allowed to use
it. When a client wants to connect, they pass their login credentials (2FA highly recommended), and if it's valid they
are allowed to proxy their networking connections through the VPN. This can be done for all public traffic (which is
the basis of the "mask your ip/access geo-restricted internet") or select traffic like to the VPC's network's private
subnets (which is what we're interested in now). There can be different features depending on your VPN product selection
(e.g. dns resolution), but this secure proxying is the heart of VPNs.

The Opta team highly encourages new users to consider a trusted VPN solution for long-term secure access needs. All major
clouds have copious amounts of articles about setting a VPN up, and several have their own VPN services, like
[AWS VPN](https://aws.amazon.com/vpn/) or [Cloud VPN](https://cloud.google.com/network-connectivity/docs/vpn/concepts/overview).
Different VPN solutions will be best depending on user-specific minutae, but personally the Opta team has had great success
with [OpenVPN](https://openvpn.net/). It's [open-sourced](https://github.com/OpenVPN/openvpn), starts with a free tier 
(max 2 concurrent user), is available on the [AWS](https://aws.amazon.com/marketplace/pp/prodview-y3m73u6jd5srk) and 
[GCP](https://console.cloud.google.com/marketplace/product/openvpn-access-server-200800/openvpn-access-server) marketplace 
for easy-installation (and lots of documentation), covers the essentials, and very simple to manage.

## Opta-managed VPN

Opta currently does not have a VPN module for users to quickly spin up a VPN server for secure connections. This feature
is definitely something that can be developed, but it has not been strongly asked yet, and Opta is very user driven.
So if you'd like to see this feature in the future, please join our [slack](https://slack.opta.dev/) and reach out to us
there.

# Security Concerns

As previously mentioned VPN is very standard, _and thus highly accepted_ security solution. Setting one up and using it
effectively for all user connections to private data is practically a checkbox in most security compliance checklists.
The TCP proxy grants such secure access quite liberally and even if the security credentials where to be highly restricted
(so very few people can create it), once created it can be used by anyone with the kubectl-port forward permissions,
and without any auditing. Those users seeking security compliance should definitely not use/allow the TCP proxy in any 
environment holding production data.
