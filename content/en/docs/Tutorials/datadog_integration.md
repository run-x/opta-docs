---
title: "Datadog Integration"
linkTitle: "Datadog Integration"
date: 2020-02-01
draft: false
description: >
Instructions on how to integrate your environment with Datadog
---

So, just to make sure we're all on the same page, [Datadog](https://www.datadoghq.com/) is a cloud monitoring/security
company many folks like to use. They do logging, events, statistics, application performance metrics (apms), etc... 
If you don't know them please check them out so that you may have an educated opinion on liking/not liking them (rest
assured, the needs mentioned above are the core of SRE, you _will_ have to address them before growing too big, and
Datadog is a big figure in that product market).

One of the main integrations they support is with Kubernetes, which is the platform opta is using to run your apps. With
this integration you can have:
* Metrics on both the whole cluster (e.g. how many servers are we running? How much cpu/memory are
they using? How many containers does each have?).
* Metrics on the individual app (e.g. how much memory/cpu are our containers
running? How often are they dying).
* Custom metrics endpoint  
* Events tracking changes in your environment (e.g. service x has just deployed new version).
* Application performance metrics.
* Log storage/forwarding from your containers.

For opta users, we created an opta module "datadog" for setting this up. All you gotta do is add it in your environment
opta yaml like so:
```yaml
name: staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: aws-base
  - type: aws-dns
    domain: staging.example.com
  - type: aws-eks
  - type: k8s-base
  - type: datadog # Yes, just one line!
```
Run opta apply once more, where opta will prompt you to add your datadog key (only the first time, it's securely stored
for successive runs), and that's it! Logs are gathered from stdout, and the APM and custom metric envars will be
setup and ready to use on all your application containers. Every piece of data coming from the environment will be
tagged with `env` set to the layer name, and service deployments will have a `service` tag set to its layer name and
`version` set to the image tag used.

For a high level view of your cluster, you can view your kubernetes dashboards on the following url:
https://app.datadoghq.com/screen/integration/86/kubernetes-overview