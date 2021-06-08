---
title: "Cloud agnostic environment modules"
linkTitle: "Cloud agnostic"
date: 2020-02-01
draft: false
weight: 3
description:
---
## datadog
This module setups the [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/?tab=helm) integration onto
the EKS cluster created for this environment. Please read the [datadog tutorial](/observability/datadog) for all the
details of the features.

*Fields*
None. It'll prompt the use for a valid api key the first time it's run, but nothing else, and nothing in the yaml.

*Outputs*
None

## runx

Integrate with the RunX UI. This UI gives you an overview of all your
environments and services. Talk to the RunX team to get set up: info@runx.dev!

![image alt text](/images/runx-dashboard.png)
