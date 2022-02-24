---
title: "Cron jobs"
linkTitle: "Cron jobs"
date: 2022-01-03
draft: false
description: >
  How to run Cron jobs with Opta
---

With Opta, you can easily create cron jobs - jobs that run on a schedule. This can now be done either
with the `helm-chart` (legacy) or the `k8s-service` opta module.

## Using K8s Service
The k8s-service module for [AWS](/reference/aws/service_modules/aws-k8s-service) or
[GCP](/reference/gcp/service_modules/gcp-k8s-service) supports adding a list of cron job to Kubernetes service 
deployments via the `cron_jobs` field. To this field you must provide as input an execution 
[schedule](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax),
and an array dictating the command to run. If one wishes to simply run a cron job as part of this service
they may set the min and max containers to zero like so:

```yaml
name: hello-cron
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - name: app
    type: k8s-service
    image: kennethreitz/httpbin
    min_containers: 0
    max_containers: 0
    port:
      http: 80
    cron_jobs:
      - commands:
        - /bin/sh
        - -c
        - 'echo "Hello world!"'
        schedule: "* * * * *"
```

Run:
```
opta apply -c hello-cron.yaml
```

Once the command is complete, you can see the cron jobs.

```
kubectl get all -n hello-cron                                    
NAME                                                READY   STATUS      RESTARTS   AGE
pod/hello-cron-app-k8s-service-0-27428021-tw4ns   0/1     Completed   0          2m17s
pod/hello-cron-app-k8s-service-0-27428022-t6n7s   0/1     Completed   0          77s
pod/hello-cron-app-k8s-service-0-27428023-wqscg   0/1     Completed   0          17s

NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/app   ClusterIP   172.20.165.235   <none>        80/TCP    84d

NAME                                           SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/hello-cron-app-k8s-service-0   * * * * *   False     0        20s             5h

NAME                                                COMPLETIONS   DURATION   AGE
job.batch/hello-cron-app-k8s-service-0-27428021   1/1           2s         2m20s
job.batch/hello-cron-app-k8s-service-0-27428022   1/1           2s         80s
job.batch/hello-cron-app-k8s-service-0-27428023   1/1           2s         20s
```

```
kubectl logs -n hello-cron   hello-cron-app-k8s-service-0-27428023-wqscg                                  
Hello world!
```

## Using Helm Chart (legacy)
Alternatively, one can use the Opta [helm-chart](https://github.com/ameijer/k8s-as-helm/tree/master/charts/cronjob) 
module to apply a chart which deploys a cron job. For instance, one may use the following:

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
