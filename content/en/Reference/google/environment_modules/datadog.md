---
title: "datadog"
linkTitle: "datadog"
date: 2021-07-21
draft: false
weight: 1
description: Integrates datadog for observability
---

This module setups the [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/?tab=helm) integration onto
the kubernetes cluster created for this environment. Please read the [datadog tutorial](features/observability/datadog) for all the
details of the features.

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `api_key` | Datadog API key. If you don't provide this in the yaml, Opta will prompt you for it and store it in secrets. | `None` | False |
| `timeout` | Time to wait for this module to stabilize. | `600` | False |
| `values` | Additional configuration for datadog. [Available options](https://github.com/DataDog/helm-charts/blob/master/charts/datadog/README.md#values) | `{}` | False |
| `chart_version` | Datadog Helm chart version. [Available versions](https://github.com/DataDog/helm-charts/releases) | `2.30.2` | False |