---
title: "datadog"
linkTitle: "datadog"
date: 2021-07-21
draft: false
weight: 1
description: Integrates datadog for observability
---

This module setups the [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/?tab=helm) integration onto
the cluster created for this environment. Please read the [datadog tutorial](/observability/datadog) for all the
details of the features.

### Fields

- `api_key` -- Optional. Datadog API key. If you don't provide this in the yaml, opta will prompt you for it and store it in secrets.
- `timeout` -- Optional. Time to wait for this module to stabilize. Default 600 (seconds)
- `values` -- Optional. Additional configuration for datadog. [Available options](https://github.com/DataDog/helm-charts/blob/master/charts/datadog/README.md#values)

### Outputs

None
