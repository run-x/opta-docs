---
title: "k8s-service"
linkTitle: "k8s-service"
date: 2021-07-21
draft: false
description: Deploys a kubernetes app
---

The most important module for deploying apps, `k8s-service` deploys a kubernetes app on Azure.
It deploys your service as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

### Fields

- `port` -- Required. Specifies what port your app was made to be listened to. Currently it must be a map of the form
  `http: [PORT_NUMBER_HERE]` or `tcp: [PORT_NUMBER_HERE]`. Use http if you just have a vanilla http server and tcp for
  websockets.
- `min_containers` -- Optional. The minimum number of replicas your app can autoscale to. Default 1
- `max_containers` -- Optional. The maximum number of replicas your app can autoscale to. Default 3
- `image` -- Required. Set to AUTO to create a private repo for your own images. Otherwise attempts to pull image from public dockerhub
- `env_vars` -- Optional. A map of key values to add to the container as environment variables (key is name,
  value is value).
  ```yaml
  env_vars:
    FLAG: "true"
  ```
- `secrets` -- Optional. A list of secrets to add as environment variables for your container. All secrets must be set
  following the [secrets instructions](/miscellaneous/secrets) prior to deploying the app.
- `autoscaling_target_cpu_percentage` -- Optional. See the [autoscaling]({{< relref "#autoscaling" >}}) section. Default 80
- `autoscaling_target_mem_percentage` -- Optional. See the [autoscaling]({{< relref "#autoscaling" >}}) section. Default 80
- `healthcheck_path` -- Optional. See the See the [liveness/readiness]({{< relref "#livenessreadiness-probe" >}}) section. 
- `resource_request` -- Optional. See the [container resources]({{< relref "#container-resources" >}}) section. Default `null` (i.e., no user-specified healthchecks)
  ```yaml
  cpu: 100 # in millicores
  memory: 128 # in megabytes
  ```
  CPU is given in millicores, and Memory is in megabytes.
- `public_uri` -- Optional. The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"

### Outputs

- `docker_repo_url` -- The url of the docker repo created to host this app's images in this environment. Does not exist
  when using external images.

### Limitations

This is nigh-identical to the original AWS version, save that (due to the new IAM method) it is not possible to pass in
IAM permissions at the moment. This will be addressed in accordance to need from users.
