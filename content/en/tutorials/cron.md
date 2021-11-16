---
title: "Cron jobs"
linkTitle: "Cron jobs"
date: 2021-11-15
draft: false
description: >
  How to run Cron jobs with Opta
---

With Opta, you can easily create cron jobs - jobs that run on a schedule.
To create a job, you need to add the following module to your yaml file:

```
name: hello
environments:
  - name: # env name
    path: # path to env file
modules:
  - type: helm-chart
    repository: https://ameijer.github.io/k8s-as-helm/
    chart: cronjob
    chart_version: 1.0.0
    values:
      schedule: "* * * * *"
      restartPolicy: Never
      containers:
        hello:
          image: busybox
          extraSettings:
            command:
              - /bin/sh
              - -c
              - date; echo Hello from the Kubernetes cluster
```

Once the file is ready, just run `opta apply -c <file-path>` and your job will
be set up.

Note that this is implemented via the [k8s-as-helm](https://github.com/ameijer/k8s-as-helm/tree/master/charts/cronjob) library. So you can use all the configurations that are available there.
