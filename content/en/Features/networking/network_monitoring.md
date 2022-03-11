---
title: "Network Monitoring"
linkTitle: "Network Monitoring"
date: 2022-03-11
weight: 3
draft: false
description: >
  How to monitor the network
---

### Cloud provider network networking

Each cloud provider has some preconfigured service to monitor networking such as [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/), [Google operations suite](https://cloud.google.com/products/operations) and [Azure Monitor](https://azure.microsoft.com/en-us/services/monitor/).

### Linkerd Viz

Linkerd comes with an optional dashboard solution known as [Linkerd Viz](https://linkerd.io/2.11/features/dashboard/).
It is not installed by default due to the non-negligible resource requirement (it installs Prometheus and Grafana
as well as a few smaller tools), but can be easily added with the following commands: 

```shell
curl -fsL https://run.linkerd.io/install | sh   # Install linkerd CLI
linkerd viz install | kubectl apply -f -        # Install linkerd monitoring stack
linkerd viz dashboard                           # open the dashboard
```

### Datadog

Datadog offers a [Network Monitoring](https://www.datadoghq.com/product/network-monitoring/network-performance-monitoring/) solution.
<br/>
It can be installed through an opta module ([see documentation](/features/observability/datadog/))
