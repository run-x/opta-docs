---
title: "Azure service modules"
linkTitle: "Azure"
date: 2020-02-01
draft: false
description:
---

## postgres
This module creates a postgres [Azure Database for PostgreSQL](https://azure.microsoft.com/en-us/services/postgresql/) database. It is made with
the [private link](https://docs.microsoft.com/en-us/azure/postgresql/concepts-data-access-and-security-private-link), ensuring private communication.

*Fields*
* `sku_name` -- Optional. The name of the SKU, follows the tier + family + cores pattern for Azure postgres [instances](https://docs.microsoft.com/en-us/azure/postgresql/concepts-pricing-tiers).
  Default "GP_Gen5_4"
* `engine_version` -- Optional. The major version of the database to use. Default 11

*Linking*

When linked to a k8s-service, it adds connection credentials to your container's environment variables as:

* `{module_name}_db_user`
* `{module_name}_db_password`
* `{module_name}_db_name`
* `{module_name}_db_host`

In the [modules reference](/modules-reference) example, the _{module\_name}_ would be replaced with `rds`

The permission list can optionally have one entry which should be a map for renaming the default environment variable
names to a user-defined value:

```yaml
    links:
      - db:
        - db_user: DBUSER
          db_host: DBHOST
          db_name: DBNAME
          db_password: DBPASS
```
If present, this map must have renames for all 4 fields.

## redis
This module creates a redis cache via [Azure Cache](https://azure.microsoft.com/en-us/services/cache/).
It is made with their standard high availability offering, but (unlike in AWS) there is no
[encryption at rest](https://techcommunity.microsoft.com/t5/azure-paas-blog/encryption-on-azure-cache-for-redis/ba-p/1800449),
but encryption in-traffic is enforced. It is made in the with [private link](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-private-link)
ensuring private communication.

_NOTE: UNLIKE IN GCP OR AWS, AZURE'S REDIS PORT IS 6380, NOT 6379_

*Fields*
* `sku_name` -- The SKU of Azure Cache's Redis to use. `Basic`, `Standard` and `Premium`. Defaults to Standard
* `family` -- The family/pricing group to use. Optionas are `C` for Basic/Standard and `P` for Premium. Defaults to C
* `capacity` -- The [size](https://azure.microsoft.com/en-us/pricing/details/cache/) (see the numbers following the C or P)
  of the Redis cache to deploy. Defaults to 2

*Linking*

When linked to a k8s-service, it adds connection credentials to your container's environment variables

* `{module_name}_cache_auth_token` -- The auth token/password of the cluster.
* `{module_name}_cache_host` -- The host to contact to access the cluster.

In the [modules reference](/modules-reference), the _{module\_name}_ would be replaced with `cache`

The permission list can optionally have one entry which should be a map for renaming the default environment variable
names to a user-defined value:

```yaml
    links:
      - db:
        - cache_host: CACHEHOST
          cache_auth_token: CACHEPASS
```
If present, this map must have renames for all 2 fields.

## k8s-service
The most important module for deploying apps, azure-k8s-service deploys a kubernetes app on azure.
It deploys your service as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

_Note_: This is nigh-identical to the original AWS version, save that (due to the new IAM method) it is not possible to pass in
IAM permissions at the moment. This will be addressed in accordance to need from users.

*Fields*
* `port` -- Required. Specifies what port your app was made to be listened to. Currently it must be a map of the form
  `http: [PORT_NUMBER_HERE]` or `tcp: [PORT_NUMBER_HERE]`. Use http if you just have a vanilla http server and tcp for
  websockets.
* `min_containers` -- Optional. The minimum number of replicas your app can autoscale to. Default 1
* `max_containers` -- Optional. The maximum number of replicas your app can autoscale to. Default 3
* `image` -- Required. Set to AUTO to create a private repo for your own images. Otherwise attempts to pull image from public dockerhub
* `env_vars` -- Optional. A map of key values to add to the container as environment variables (key is name,
  value is value).
  ```yaml
  env_vars:
    FLAG: "true"
  ```
* `secrets` -- Optional. A list of secrets to add as environment variables for your container. All secrets must be set
  following the [secrets instructions](/miscellaneous/secrets) prior to deploying the app.
* `autoscaling_target_cpu_percentage` --  Optional. See the [autoscaling]({{< relref "#autoscaling" >}}) section. Default 80
* `autoscaling_target_mem_percentage` -- Optional. See the [autoscaling]({{< relref "#autoscaling" >}}) section. Default 80
* `healthcheck_path` -- Optional. See the See the [liveness/readiness]({{< relref "#livenessreadiness-probe" >}}) section. Default "/healthcheck"
* `resource_request` -- Optional. See the [container resources]({{< relref "#container-resources" >}}) section. Default
  ```yaml
  cpu: 100  # in millicores
  memory: 128  # in megabytes
  ```
  CPU is given in millicores, and Memory is in megabytes.
* `public_uri` -- Optional. The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"


*Outputs*
* `docker_repo_url` -- The url of the docker repo created to host this app's images in this environment. Does not exist
  when using external images.
