---
title: "k8s-service"
linkTitle: "k8s-service"
date: 2021-07-21
draft: false
weight: 1
description: Deploys a kubernetes app
---

The most important module for deploying apps, k8s-service deploys a kubernetes app.
It deploys your service as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

## Features

### External/Internal Image

This module supports deploying from an "external" image repository (currently only public ones supported)
by setting the `image` field to the repo (e.g. "kennethreitz/httpbin" in the examples). If you set the value to "AUTO" however,
it will automatically create a secure container repository with ECR on your account. You can then use the `Opta push`
command to push to it!

### Healthcheck Probe

One of the benefits of K8s is that it comes with built-in checks for the responsiveness of your server. These are called
[_liveness_ and _readiness_ probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).

tl;dr An (optional) liveness probe determines whether your server should be restarted, and an (optional) readiness probe determines if traffic should
be sent to a replica or be temporarily rerouted to other replicas. Essentially smart healthchecks. For websockets Opta
just checks the tcp connection on the given port.

### Autoscaling

As mentioned, autoscaling is available out of the box. We currently only support autoscaling
based on the pod's cpu and memory usage, but we hope to soon offer the ability to use 3rd party metrics like datadog
to scale. As mentioned in the k8s docs, the horizontal pod autoscaler (which is what we use) assumes a linear relationship between # of replicas
and cpu (twice the replicas means half expected cpu usage), which works well assuming low overhead.
The autoscaler then uses this logic to try and balance the cpu/memory usage at the percentage of request. So, for example,
if the target memory is 80% and we requested 100mb, then it'll try to keep the memory usage at 80mb. If it finds that
the average memory usage was 160mb, it would logically try to double the number of replicas.

### Container Resources

One of the other benefits of kubernetes is that a user can have fine control over the [resources used by each of their containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
A user can control the cpu, memory and disk usage with which scheduling is made, and the max limit after which the container is killed.
With Opta, we expose such settings to the user, while keeping sensible defaults.

_NOTE_ We expose the resource requests and set the limits to twice the request values.

### Ingress

You can control if and how you want to expose your app to the world! Check out
the [Ingress](/features/dns) docs for more details.

### Persistent Storage
A user can now specify persistent storage to be provisioned for your servers and kept intact over your different
deployments + scaling. This will take form of a list of entries holding a `size` (size of the storage to create in 
gigabytes) and `path` (path to put it on your server's container) field, like so:
```yaml
.
.
.
modules:
  - name: app
    type: k8s-service
    image: kennethreitz/httpbin
    min_containers: 2
    max_containers: "{vars.max_containers}"
    liveness_probe_path: "/get"
    readiness_probe_path: "/get"
    port:
      http: 80
    public_uri: "subdomain1.{parent.domain}"
    persistent_storage:
      - path: "/DESIRED/PATH1"
        size: 20 # 20 GB
      - path: "/DESIRED/PATH2"
        size: 30 # 30 GB
.
.
.
```
Under the hood, an AWS EBS volume is being created to house your data for each coexisting server container of your app.

_WARNING_ Switching between having the persistent_storage field set or not will lead to some minor downtime as the
underlying resource kind is being switched.

_NOTE_ because of the nature of these volumes, they will not be cleaned up automatically unless during a service 
destruction. If you wish to release the EBS volumes for whatever reason you will need to manually do so by deleting
the kubernetes persistent volume claims.

### Tolerations

Opta gives you the option of adding [taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
to the nodes created in this nodepool, and thusly the ability to add _tolerations_ for said taints. The official 
documentation gives an excellent detailed summary, but in short one can use taints to stop workloads from running in 
said nodes unless they have a matching toleration. Simply provide a list of desired tolerations as inputs like so:
```yaml
  - name: app
    type: k8s-service
    image: AUTO
    healthcheck_path: "/get"
    port:
      http: 80
    tolerations:
      - key: instancetype
        value: memoryoptimized
        effect: "NoExecute"
      - key: team
        value: booking
        # Tolerates for default effect of NoSchedule
      - key: highpriority
        # Tolerates for default value of opta
```

Please refer to the taints specified in your environment Opta manifests to know what matching tolerations are right 
for you.

### Cron Jobs

Opta gives you the option of adding a list of cron jobs to run as part of this service. This is done via the `cron_jobs`
field which a user can fill with entries for each con job in mind. Each entry must specify a command in array format
(for most cases simply specify the shell you wish to use, the `-c` flag and the executable to run), as well as a
schedule following the [Cron Syntax](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax).
The cron jobs will use the same resource requests/limits as the servers.

For example, here is a service which has a cron job that runs every minute and simply outputs "Hello world!" to stdout:

```yaml
  - name: app
    type: k8s-service
    image: AUTO
    healthcheck_path: "/get"
    port:
      http: 80
    cron_jobs:
      - commands:
        - /bin/sh
        - -c
        - 'echo "Hello world!"'
        schedule: "* * * * *"
```

{{% alert title="Pure Cron Jobs" color="info" %}}
If a user wishes to just have a cron job and no service, then they could simply set the min/max containers to
0.
{{% /alert %}}

{{% alert title="Warning" color="warning" %}}
Cron Jobs are currently created outside the default linkerd service mesh.
{{% /alert %}}

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `image` | Set to AUTO to create a private repo for your own images. Otherwises attempts to pull image from public dockerhub | `AUTO` | True |
| `port` | Specifies what port your app was made to be listened to. Currently it must be a map of the form `http: [PORT_NUMBER_HERE]` or `websocket: [PORT_NUMBER_HERE]`. Use `http` if you just have a vanilla http server and `websocket` for websockets.  | *none* | False |
| `ports` | Specifies which port(s) your app exposes. | *none* | False |
| `probe_port` | The name of the port to use for readiness and liveness probes. Defaults to the first port listed. | *none* | False |
| `min_containers` | The minimum number of replicas your app can autoscale to. | `1` | False |
| `max_containers` | The maximum number of replicas your app can autoscale to. | `3` | False |
| `autoscaling_target_cpu_percentage` | See the [autoscaling](https://docs.opta.dev/reference/aws/modules/aws-k8s-service/#autoscaling) section. | `80` | False |
| `autoscaling_target_mem_percentage` | See the [autoscaling](https://docs.opta.dev/reference/aws/modules/aws-k8s-service/#autoscaling) section. | `80` | False |
| `secrets` | Deprecated, see [secrets instructions](/features/secrets). | `[]` | False |
| `env_vars` | A map of key values to add to the container as environment variables (key is name, value is value). ```yaml env_vars:  FLAG: "true" ```  | `[]` | False |
| `healthcheck_path` | See the See the [liveness/readiness](https://docs.opta.dev/reference/aws/modules/aws-k8s-service/#healthcheck-probe) section. Default `null` (i.e., no user-specified healthchecks) | `None` | False |
| `liveness_probe_path` | Use if liveness probe != readiness probe | `None` | False |
| `readiness_probe_path` | Use if liveness probe != readiness probe | `None` | False |
| `initial_liveness_delay` | Use if the initial delay needs to be changed. | `30` | False |
| `initial_readiness_delay` | Use if the initial delay needs to be changed. | `30` | False |
| `consistent_hash` | Use [consistent hashing](https://www.nginx.com/resources/wiki/modules/consistent_hash/) | `None` | False |
| `sticky_session` | Use [sticky sessions](https://stackoverflow.com/questions/10494431/sticky-and-non-sticky-sessions) via cookies for your service (first request will send you a cookie called opta_cookie which you should add on future requests). | `False` | False |
| `sticky_session_max_age` | If the sticky session is enabled, how long should the cookie last? | `86400` | False |
| `resource_request` | See the [container resources](https://docs.opta.dev/reference/aws/modules/aws-k8s-service/#container-resources) section. Default ```yaml cpu: 100 # in millicores memory: 128 # in megabytes ``` CPU is given in millicores, and Memory is in megabytes.  | `{'cpu': 100, 'memory': 128}` | False |
| `public_uri` | The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"  | `[]` | False |
| `keep_path_prefix` | Should we keep the prefix path which you set in the public uri when forwarding requests to your service? | `False` | False |
| `additional_iam_policies` | A list of extra IAM role policies not captured by Opta which you wish to give to your service. | `[]` | False |
| `links` | A list of extra IAM role policies not captured by Opta which you wish to give to your service. | `[]` | False |
| `persistent_storage` | A list persistent storages to add to each instance of your service (need to give a `size` which is the size in GB for the storage volume to be, and `path` which is the path in the filesystem of each instance to place it under)  | `[]` | False |
| `ingress_extra_annotations` | These are extra annotations to add to ingress objects  | `{}` | False |
| `tolerations` | Taint tolerations to add to the pods. | `[]` | False |
| `cron_jobs` | A list of cronjobs to execute as part of this service | `[]` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `docker_repo_url` | The url of the docker repo created to host this app's images in this environment. Does not exist when using external images. |
| `current_image` | The full name plus tag of the docker imge used by the deployment. |