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
the [Ingress](/tutorials/ingress) docs for more details.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `image` | Set to AUTO to create a private repo for your own images. Otherwises attempts to pull image from public dockerhub | `None` | True |
| `port` | Specifies what port your app was made to be listened to. Currently it must be a map of the form `http: [PORT_NUMBER_HERE]` or `tcp: [PORT_NUMBER_HERE]`. Use http if you just have a vanilla http server and tcp for websockets.  | `None` | True |
| `min_containers` | The minimum number of replicas your app can autoscale to. | `1` | False |
| `max_containers` | The maximum number of replicas your app can autoscale to. | `3` | False |
| `autoscaling_target_cpu_percentage` | See the [autoscaling]({{< relref "#autoscaling" >}}) section. | `80` | False |
| `autoscaling_target_mem_percentage` | See the [autoscaling]({{< relref "#autoscaling" >}}) section. | `80` | False |
| `secrets` | A list of secrets to add as environment variables for your container. All secrets must be set following the [secrets instructions](/tutorials/secrets) prior to deploying the app. | `[]` | False |
| `env_vars` | A map of key values to add to the container as environment variables (key is name, value is value). ```yaml env_vars:  FLAG: "true" ```  | `[]` | False |
| `healthcheck_path` | See the See the [liveness/readiness]({{< relref "#livenessreadiness-probe" >}}) section. Default `null` (i.e., no user-specified healthchecks) | `None` | False |
| `liveness_probe_path` | Use if liveness probe != readiness probe | `None` | False |
| `readiness_probe_path` | Use if liveness probe != readiness probe | `None` | False |
| `consistent_hash` | Use [consistent hashing](https://www.nginx.com/resources/wiki/modules/consistent_hash/) | `None` | False |
| `sticky_session` | Use [sticky sessions](https://stackoverflow.com/questions/10494431/sticky-and-non-sticky-sessions) via cookies for your service (first request will send you a cookie called opta_cookie which you should add on future requests). | `False` | False |
| `sticky_session_max_age` | If the sticky session is enabled, how long should the cookie last? | `86400` | False |
| `resource_request` | See the [container resources]({{< relref "#container-resources" >}}) section. Default ```yaml cpu: 100 # in millicores memory: 128 # in megabytes ``` CPU is given in millicores, and Memory is in megabytes.  | `{'cpu': 100, 'memory': 128}` | False |
| `public_uri` | The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"  | `[]` | False |
| `keep_path_prefix` | Should we keep the prefix path which you set in the public uri when forwarding requests to your service? | `False` | False |
| `additional_iam_policies` | A list of extra IAM role policies not captured by Opta which you wish to give to your service. | `[]` | False |
| `links` | A list of extra IAM role policies not captured by Opta which you wish to give to your service. | `[]` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `docker_repo_url` | The url of the docker repo created to host this app's images in this environment. Does not exist when using external images. |