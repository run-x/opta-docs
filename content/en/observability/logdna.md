---
title: "LogDNA Integration"
linkTitle: "LogDNA Integration"
date: 2021-07-21
draft: false
description: >
  Instructions on how to integrate your environment with LogDNA
---

With the LogDNA(https://logdna.com) integration, all the stdout from your services will be sent to LogDNA.

To enable this, add the following module to your environment opta.yml:

```yaml
name: <name>
org_name: <org>
providers: ...
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
  - type: helm-chart # <-- Add this for LogDNA support
    chart: agent
    repository: https://assets.logdna.com/charts
    chart_version: 203.1.0
    values:
      logdna:
        key: <your ingestion key>
        tags: staging # any custom tags that you need
```

Run `opta apply` and that's it! You should see your logs in logDNA shortly.
