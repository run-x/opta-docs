---
title: "GCP service modules"
linkTitle: "GCP"
date: 2020-02-01
draft: false
description: 
---

## gcp-gcs
This module creates an gcs bucket for storage purposes. It is created with encryption based on the default kms key 
created for you in the base, as well as the standard AES-256 encryption.

*Fields*
* `bucket_name`-- Required. The name of the bucket to create.
* `block_public` -- Optional. Block all public access. Default true

*Outputs*
* `bucket_id` -- The id of the bucket.
* `bucket_name` -- The name of the bucket.

*Linking*

When linked to a gcp-k8s-service, this adds the necessary IAM permissions to read
(e.g. list objects and get objects) and/or write (e.g. list, get,
create, destroy, and update objects) to the given gcs bucket.
The current permissions are, "read" and "write". These need to be
specified when you add the link.

## postgres
This module creates a postgres [GCP Cloud SQL](https://cloud.google.com/sql/docs/introduction) database. It is made with
the [private service access](https://cloud.google.com/vpc/docs/private-services-access), ensuring private communication.

*Fields*
* `instance_tier` -- Optional. This is the RDS instance type used for the cloud sql instance [instances](https://cloud.google.com/sql/pricing).
  Default "db-f1-micro"
* `engine_version` -- Optional. The major version of the database to use. Default 11
* `safety` -- Optional. Set to "true", if you want to disable the database deletion in opta. You would have to manually set this "false" to enable DB deletion.

*Linking*

When linked to a k8s-service, it adds connection credentials to your container's environment variables as:

* `{module_name}_db_user`
* `{module_name}_db_password`
* `{module_name}_db_name`
* `{module_name}_db_host`

In the above example file, the _{module\_name}_ would be replaced with `rds`

The permission list is to be empty because we currently do not support giving
apps IAM permissions to manipulate a database.

## mysql
This module creates a MySQL [GCP Cloud SQL](https://cloud.google.com/sql/docs/introduction) database. It is made with
the [private service access](https://cloud.google.com/vpc/docs/private-services-access), ensuring private communication.

*Fields*
* `instance_tier` -- Optional. This is the RDS instance type used for the cloud sql instance [instances](https://cloud.google.com/sql/pricing).
  Default "db-f1-micro"
* `engine_version` -- Optional. The major version of the database to use. Default 11
* `safety` -- Optional. Set to "true", if you want to disable the database deletion in opta. You would have to manually set this "false" to enable DB deletion.

*Linking*

When linked to a k8s-service, it adds connection credentials to your container's environment variables as:

* `{module_name}_db_user`
* `{module_name}_db_password`
* `{module_name}_db_name`
* `{module_name}_db_host`

In the above example file, the _{module\_name}_ would be replaced with `rds`

The permission list is to be empty because we currently do not support giving
apps IAM permissions to manipulate a database.

## redis
This module creates a redis cache via [Memorystore](https://cloud.google.com/memorystore/docs/redis/redis-overview). 
It is made with their standard high availability offering, but (unlike in AWS) there is no
[encryption at rest](https://stackoverflow.com/questions/58032778/gcp-cloud-memorystore-data-encryption-at-rest)
and in-transit encryption is not offered as terraform support is in beta. It is made in the with private service access
ensuring private communication.

*Fields*
* `node_type` -- Optional. This is the redis instance type used for the [instances](https://aws.amazon.com/elasticache/pricing/).
  Default cache.m4.large.
* `redis_version` - the Memorystore offered redis version to use. Default REDIS_5_0

*Linking*

When linked to a k8s-service, it adds connection credentials to your container's environment variables

* `{module_name}_cache_auth_token` -- The auth token/password of the cluster.
* `{module_name}_cache_host` -- The host to contact to access the cluster.

In the above example file, the _{module\_name}_ would be replaced with `redis`

## k8s-service
The most important module for deploying apps, gcp-k8s-service deploys a kubernetes app on gcp.
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
* `image` -- Required. Set to AUTO to create a private repo for your own images. Otherwises attempts to pull image from public dockerhub
* `env_vars` -- Optional. A list of maps holding name+value fields for envars to add to your container
  ```yaml
    - name: FLAG
      value: "true"
  ```
* `secrets` -- Optional. Same format as env_vars, but these values will be stored in the secrets resource, not directly
  in the pod spec.
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
