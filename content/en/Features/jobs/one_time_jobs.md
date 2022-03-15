---
title: "One-time Jobs"
linkTitle: "One-time Jobs"
date: 2022-01-03
draft: false
description: How to run one-off jobs with Opta
---

On occasion one may wish to run one-time jobs for their application, e.g. to run migrations. This can currently be 
achieved with opta by using the helm chart module to create a helm chart which runs the one-time job.  For example,
the following yaml will create a one-time job using the image busybox and run the command 
`/bin/sh -c "date; echo Hello from the Kubernetes cluster"`:

```yaml
# hello-cron.yaml
name: hello-job
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - type: helm-chart
    namespace: hello # Note that this will run in the "hello" namespace
    create_namespace: true # In this example, the "hello" namespace is not pre-existing so we must create it.
    # see https://github.com/ameijer/k8s-as-helm for reference
    repository: https://ameijer.github.io/k8s-as-helm/
    chart: job
    chart_version: 1.0.0
    values:
      restartPolicy: Never
      containers:
        hello:
          image: busybox
          extraSettings:
            env:
              - name: ENVAR
                value: VALUE1
            command:
              - /bin/sh
              - -c
              - date; echo Hello from the Kubernetes cluster
```

The job will now be run as part of the next opta apply/deploy.
You can monitor the progress of this job by inspecting the pod created for this job like so:

```shell
$ kubectl get pods -n hello-job
NAME                        READY   STATUS      RESTARTS   AGE
hello-job-helmchart-jnwx9   0/1     Completed   0          4h46m
$ kubectl logs -n hello-job hello-job-helmchart-jnwx9
Thu Mar  3 01:37:31 UTC 2022
Hello from the Kubernetes cluster4
```

{{% alert title="Warning" color="warning" %}}
Upon each completion, be sure to destroy the job before rerunning with a new configuration as jobs are one-time
and by definition can not be rerun, just deleted and recreated from scratch.
{{% /alert %}}
