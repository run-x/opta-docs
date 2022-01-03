---
title: "Cron jobs"
linkTitle: "Cron jobs"
date: 2022-01-03
draft: false
description: >
  How to run Cron jobs with Opta
---

With Opta, you can easily create cron jobs - jobs that run on a schedule.
To create a job, you need to add the following module to your yaml file:

```yaml
# hello-cron.yaml
name: hello-cron
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - type: helm-chart
    namespace: hello
    # see https://github.com/ameijer/k8s-as-helm for reference
    repository: https://ameijer.github.io/k8s-as-helm/
    chart: cronjob
    chart_version: 1.0.0
    values:
      schedule: "* * * * *" # At every minute
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

Run:
```
opta apply -c hello-cron.yaml
```

Once the command is complete, you can see the cron jobs.

```
kubectl get all -n hello                                    
NAME                                        READY   STATUS      RESTARTS   AGE
pod/hello-cron-hellocron-1640319960-v2bzs   0/1     Completed   0          2m35s
pod/hello-cron-hellocron-1640320020-kvtc5   0/1     Completed   0          94s
pod/hello-cron-hellocron-1640320080-ms2md   0/1     Completed   0          34s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   29h

NAME                                        COMPLETIONS   DURATION   AGE
job.batch/hello-cron-hellocron-1640319960   1/1           2s         2m37s
job.batch/hello-cron-hellocron-1640320020   1/1           2s         96s
job.batch/hello-cron-hellocron-1640320080   1/1           2s         36s

NAME                                 SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/hello-cron-hellocron   * * * * *   False     0        45s             15m
```

```
kubectl logs -n hello  hello-cron-hellocron-1640319960-v2bzs                                     
Fri Dec 24 04:26:10 UTC 2021
Hello from the Kubernetes cluster
```

Note that this is implemented via the [k8s-as-helm](https://github.com/ameijer/k8s-as-helm/tree/master/charts/cronjob) library. So you can use all the configurations that are available there.
