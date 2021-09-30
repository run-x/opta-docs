---
title: "helm-chart"
linkTitle: "helm-chart"
date: 2021-07-21
draft: false
weight: 1
description: Plugs a custom helm chart into your Opta k8s cluster
---


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `chart` | Name of the helm chart. Note that you don't need to use `<repo_name>/<chart_name>` - as repo is specified separately. Just do `<chart_name>`. If you're using a local chart, then this will be the path to the chart.  | `None` | True |
| `repository` | The helm repository to use (null means local chart) | `None` | False |
| `namespace` | The kubernetes namespace to put the chart in | `default` | False |
| `create_namespace` | Create namespace as well. | `False` | False |
| `atomic` | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. | `True` | False |
| `cleanup_on_fail` | Allow deletion of new resources created in this upgrade when upgrade fails | `True` | False |
| `chart_version` | User side of the version of the helm chart to install | `None` | False |
| `values_file` | Path to a values file. | `None` | False |
| `values` | Values override. | `{}` | False |
| `timeout` | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). | `600` | False |
| `dependency_update` | Runs helm dependency update before installing the chart. | `True` | False |