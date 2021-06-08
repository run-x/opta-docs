---
title: "LogDNA Integration"
linkTitle: "LogDNA Integration"
date: 2020-06-08
draft: false
description: >
  Instructions on how to integrate your environment with LogDNA
---

With the LogDNA(https://logdna.com) integration, all the stdout from your services will be sent to LogDNA.

To enable this, create a new opta yaml file - let's say `logdna.yml`:
```yaml
name: logdna
environments:
  - name: staging
    path: "../opta.yml" # path to your environment opta yml
modules:
  - type: helm-chart
    chart: agent
    repository: https://assets.logdna.com/charts
    version: 203.1.0
    values:
      logdna:
        key: <your ingestion key>
        tags: staging # any custom tags that you need
```
Run `opta apply -c logdna.yml` and that's it! You should see your logs in logDNA shortly.
