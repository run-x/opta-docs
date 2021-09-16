---
title: "helm-chart"
linkTitle: "helm-chart"
date: 2021-07-21
draft: false
weight: 1
description: Plugs a custom helm chart into your Opta k8s cluster
---


## Fields

- `chart` - Required. Name of the helm chart.
Note that you don't need to use `<repo_name>/<chart_name>` - as repo is specified separately. Just do `<chart_name>`.
If you're using a local chart, then this will be the path to the chart.

- `repository` - Optional. The helm repository to use (null means local chart) Default None
- `namespace` - Optional. The kubernetes namespace to put the chart in Default default
- `create_namespace` - Optional. Create namespace as well. Default False
- `atomic` - Optional. If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Default True
- `cleanup_on_fail` - Optional. Allow deletion of new resources created in this upgrade when upgrade fails Default True
- `version` - Optional. The version of the helm chart to install Default None
- `values_file` - Optional. Path to a values file. Default None
- `values` - Optional. Values override. Default {}
- `timeout` - Optional. Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Default 600
- `dependency_update` - Optional. Runs helm dependency update before installing the chart. Default True

## Outputs

