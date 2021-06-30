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
* `api_key` -- Optional. Datadog API key. If you don't provide this in the yaml, opta will prompt you for it and store it in secrets.
* `timeout` -- Optional. Time to wait for this module to stabilize. Default 600 (seconds)
* `values` -- Optional. Additional configuration for datadog. [Available options](https://github.com/DataDog/helm-charts/blob/master/charts/datadog/README.md#values)

*Outputs*
None

## runx

Integrate with the RunX UI. This UI gives you an overview of all your
environments and services. Talk to the RunX team to get set up: info@runx.dev!

![image alt text](/images/runx-dashboard.png)
