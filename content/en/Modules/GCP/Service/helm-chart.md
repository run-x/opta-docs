---
title: "helm-chart"
linkTitle: "helm-chart"
date: 2021-07-21
draft: false
weight: 1
description: Plugs a custom helm chart into your opta k8s cluster
---

### Fields

- `chart` -- Name of the helm chart.

  Note that you don't need to use `<repo_name>/<chart_name>` - as repo is specified separately. Just do `<chart_name>`.

  If you're using a local chart, then this will be the path to the chart.

- `repository` -- Optional. Default = null - which means a local chart.
- `namespace` -- Optional. Default = default
- `create_namespace` -- Optional. Default = false
- `atomic` -- Optional. Default = true
- `cleanup_on_fail` -- Optional. Default = true
- `version` -- Optional for local charts and Required for remote
  charts. Default = null.
- `values_file` -- Optional. Path to a values file. Default = null
- `values` -- Optional. Values override.
- `timeout` -- Optional. Default = 300
- `dependency_update` -- Optional. Default = true

### Outputs

None
