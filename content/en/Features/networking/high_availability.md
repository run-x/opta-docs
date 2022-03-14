---
title: "High availability"
linkTitle: "High availability"
date: 2022-03-11
weight: 2
draft: false
description: >
  High availability to provide resiliency in case of zone outages
---

## Kubernetes Ingress - high availability

Opta can also deploy the nginx ingress in a high-availability configuration, this is done by setting the flags **nginx_high_availability** and **linkerd_high_availability** in the *k8s-base* module. That's it!

![High availability](/images/network_ingress_overview_HA.png)


Simulation of an availability zone outage:
![High availability outage](/images/network_ingress_overview_HA_outage.png)


When high availability is enabled, Opta uses 3 Availability Zones.

