---
title: "Cloud agnostic service modules"
linkTitle: "Cloud agnostic"
date: 2020-06-01
draft: false
weight: 3
description:
---

## datadog
This module setups the [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/?tab=helm) integration onto
the EKS cluster created for this environment. Please read the [datadog tutorial](/docs/tutorials/datadog) for all the
details of the features.

*Fields*
None. It'll prompt the use for a valid api key the first time it's run, but nothing else, and nothing in the yaml.

*Outputs*
None

## helm-chart

Plug in a custom helm chart in your opta k8s cluster.

*Fields*
* `chart` -- name/path to the helm chart.
* `repository` -- Optional. Default = null - which means a local chart.
* `namespace` -- Optional. Default = default
* `create_namespace` -- Optional. Default = false
* `atomic` -- Optional. Default = true
* `cleanup_on_fail` -- Optional. Default = true
* `chart_version` -- Optional. Default = null
* `values_file` -- Optional. Path to a values file. Default = null
* `values` -- Optional. Values override.
* `timeout` -- Optional. Default = 300
* `dependency_update` -- Optional. Default = true

*Outputs*
None

## runx

Integrate with the RunX UI. This UI gives you an overview of all your
environments and services. Talk to the RunX team to get set up: info@runx.dev!

![image alt text](/images/runx-dashboard.png)
