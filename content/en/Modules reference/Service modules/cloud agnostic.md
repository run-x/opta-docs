---
title: "Cloud agnostic service modules"
linkTitle: "Cloud agnostic"
date: 2020-06-01
draft: false
weight: 3
description:
---
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
