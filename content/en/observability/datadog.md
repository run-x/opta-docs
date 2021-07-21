---
title: "Datadog Integration"
linkTitle: "Datadog Integration"
date: 2021-07-21
draft: false
description: >
  Instructions on how to integrate your environment with Datadog
---

Opta provides deep integration with [Datadog](https://www.datadoghq.com/).

With this integration you can have:

- Metrics on both the whole cluster (e.g. how many servers are we running? How much cpu/memory are
  they using? How many containers does each have?).
- Metrics on the individual app (e.g. how much memory/cpu are our containers
  running? How often are they dying).
- Custom metrics endpoint
- Events tracking changes in your environment (e.g. service x has just deployed new version).
- Application performance metrics.
- Log storage/forwarding from your containers.

To enable Datadog integration, all you gotta do is add it in your environment Opta yaml like so:

```yaml
name: staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: base
  - type: dns
    domain: staging.example.com
  - type: k8s-cluster
  - type: k8s-base
  - type: datadog # Yes, just one line! Works for AWS, GCP and Azure!
```

Run `opta apply` once more, where Opta will prompt you to add your datadog key (only the first time, it's securely stored
for successive runs). Logs, APM and custom metric envars will be setup and ready to use on all your application containers. Every piece of data coming from the environment will be
tagged with `env` set to the layer name, and service deployments will have a `service` tag set to its layer name and
`version` set to the image tag used.

For a high level view of your cluster, you can view your kubernetes dashboards on the following url:
https://app.datadoghq.com/screen/integration/86/kubernetes-overview
