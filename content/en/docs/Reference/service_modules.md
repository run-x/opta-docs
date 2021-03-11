---
title: "Service Modules"
linkTitle: "Service Modules"
weight: 9
description: >
  Input and output of different Service Modules
---

# What's an Opta module?

The heart of Opta is a set of "Modules" which basically map to AWS resources that
need to get created. Opta yamls reference these under the `modules` field.


```yaml
environments:
  - name: staging
    parent: "../env/opta.yml"
name: myapp
modules:
  - name: app # This is an instance of the k8-service module type called app
    type: k8s-service
    port: 
      http: 80
    image: AUTO
    public_uri: "app.{parent[domain]}/app"
    liveness_probe_path: "/get"
    readiness_probe_path: "/get"
    env_vars:
      - name: ENV
        value: "{env}"
    links:
      - database
      - redis
  - name: mydatabase # This is an instance of the aws-rds module type called mydatabase
    type: aws-rds
  - name: myredis # This is an instance of the aws-redis module type called myredis
    type: aws-redis
```
You'll note that the module instance can have user-specified names which will come into play later with references.

## Fields
You'll note that there can be many, varying, fields per module instance such 
as "type", "env_vars", "image" etc...  These are called _fields_ and this 
is how specific data is passed into the modules.

### Names
All modules have a name field, which is used to create the name of the cloud resources in conjunction with the layer
name (root name of opta.yml). A user can specify this with the `name` field, but it defaults to the module type (without
the hyphens) if not given.

### Types
All modules have their own list of supported fields, but the one common to all is _type_. The type field is simply
the module reference (e.g. the library/package to use in this "import"). Opta currently comes with its list of valid
modules built in -- future work may allow users to specify their own.

### Linking
The k8s-service module type is the first (but not the last) module to support 
special processing. In this case, it's in regard to the _links_ field. The 
links field takes as input a list of maps with a single element where the 
key is the name of another module in the file, and the value a list of 
strings representing resource permissions.
```yaml
meta:
  parent: "../env/opta.yml"
  name: balonstagingey
modules:
  - app: # This is an instance of the k8-service module type called app
.
.
.
    links:
      database: []
      redis: []
      docdb: []
      bucket:
        - write
  - name: database # This is an instance of the aws-rds module type called database
    type: aws-rds
  - name: redis # This is an instance of the aws-redis module type called redis
    type: aws-redis
  - name: docdb
    type: aws-documentdb
  - name: bucket
    type: aws-s3
    bucket_name: "test-bucket"
```

# Module Types
Here is the list of module types for the user to use, with their inputs and outputs:

## aws-documentdb
This module creates an AWS Documentdb  cluster. It is made in the private subnets automatically created for the environment.
macro and so can only be accessed in the VPC or through some proxy (e.g. VPN). It is encrypted
at rest with a kms key created in the env setup and in transit via tls.

*Fields*
* `instance_class` -- Optional. This is the RDS instance type used for the documentdb cluster [instances](https://aws.amazon.com/documentdb/pricing/).
  Default db.r5.large

*Outputs*
* `db_user` -- DB user
* `db_password` -- DB password
* `db_host` -- DB host

*Linking*

When linked to a k8s-service, this adds connection credentials to your container
as _{module_name}\_db\_user_, _{module_name}\_db\_password_, and _{module_name}\_db\_host_.

In addition to these credentials, you also need to enable SSL encryption when
connecting ([AWS docs](https://docs.aws.amazon.com/documentdb/latest/developerguide/connect_programmatically.html)).
Fortunately, the Opta k8s-service module has already taken care of that. On linking, you'll 
find the AWS CA at `/config/rds_ca.pem"`

As an example, this is how the mongoose/node connection looks like:
```
await mongoose.connect("mongodb://<USER>:<PASSWORD>@<HOST>, {
  ssl: true,
  sslCA: require('fs').readFileSync(`/config/rds_ca.pem`)
});
```

## aws-postgres
This module creates a postgres Aurora RDS database instance. It is made in the 
private subnets automatically created during environment setup and so can only be accessed in the 
VPC or through some proxy (e.g. VPN).

*Fields*
* `instance_class` -- Optional. This is the RDS instance type used for the Aurora cluster [instances](https://aws.amazon.com/rds/instance-types/).
  Default db.r5.large
* `engine_version` -- Optional. The version of the database to use. Default 11.9.

*Outputs*
* `db_user` -- DB user
* `db_password` -- DB password
* `db_host` -- DB host
* `db_name` -- DB name

*Linking*

When linked to a k8s-service, it adds connection credentials to your container as 
_{module_name}\_db\_user_, _{module_name}\_db\_password_, _{module_name}\_db\_name_, 
and _{module_name}\_db\_host_.

The permission list is to be empty because we currently do not support giving 
apps IAM permissions to manipulate a database.

## aws-redis
This module creates a redis cache via elasticache. It is made with one failover instance across azs, and is encrypted
at rest with a kms key created in the env setup via the _init_ macro and in transit via tls. It is made in the private
subnets created by the _init macro and so can only be accessed in the VPC or through some proxy (e.g. VPN).

*Fields*
* `node_type` -- Optional. This is the redis instance type used for the [instances](https://aws.amazon.com/elasticache/pricing/). 
  Default cache.m4.large.

*Outputs*
* `cache_auth_token` -- The auth token/password of the cluster.
* `cache_host` -- The host to contact to access the cluster.

*Linking*

When linked to a k8s-service, it adds connection credentials to your container
as _{module_name}\_cache\_host_ and _{module_name}\_cache\_auth\_token_.

_NOTE_ Redis CLI will not work against this cluster because redis cli does not 
support the TLS transit encryption. There should be no trouble with any of the 
language sdks however, as they all support TLS.

## aws-s3
This module creates an S3 bucket for storage purposes. It is created with server-side AES256 encryption.

*Fields*
* `bucket_name`-- Required. The name of the bucket to create.
* `block_public` -- Optional. Block all public access. Default true
* `bucket_policy` -- Optional. A custom s3 policy json/yaml to add.

*Outputs*
* `bucket_id` -- The id/name of the bucket.
* `bucket_arn` -- The arn of the bucket.

*Linking*

When linked to a k8s-service, this adds the necessary IAM permissions to read 
(e.g. list objects and get objects) and/or write (e.g. list, get,
create, destroy, and update objects) to the given s3 bucket. 
The current permissions are (wait for it), "read" and "write". These need to be
specified when you add the link.

## k8s-service
The most important module for deploying apps, k8s-service deploys a kubernetes app.
It deploys your service as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

*Fields*
* `port` -- Required. Specifies what port your app was made to be listened to. Currently it must be a map of the form
  `http: [PORT_NUMBER_HERE]` or `tcp: [PORT_NUMBER_HERE]`. Use http if you just have a vanilla http server and tcp for
  websockets.
* `min_containers` -- Optional. The minimum number of replicas your app can autoscale to. Default 1
* `max_containers` -- Optional. The maximum number of replicas your app can autoscale to. Default 3
* `image` -- Required. Set to AUTO to create a private repo for your own images. Otherwises attempts to pull image from public dockerhub
* `env_vars` -- Optional. A list of maps holding name+value fields for envars to add to your container
  ```yaml
    - name: BLAH
      value: malarkey
  ```
* `secrets` -- Optional. Same format as env_vars, but these values will be stored in the secrets resource, not directly
  in the pod spec.
* `autoscaling_target_cpu_percentage` --  Optional. See the [autoscaling]({{< relref "#autoscaling" >}}) section. Default 80
* `autoscaling_target_mem_percentage` -- Optional. See the [autoscaling]({{< relref "#autoscaling" >}}) section. Default 80
* `liveness_probe_path` -- Optional. See the See the [liveness/readiness]({{< relref "#livenessreadiness-probe" >}}) section. Default "/healthcheck"
* `readiness_probe_path` -- Optional. See the See the [liveness/readiness]({{< relref "#livenessreadiness-probe" >}}) section. Default "/healthcheck"
* `resource_request` -- Optional. See the [container resources]({{< relref "#container-resources" >}}) section. Default
  ```yaml
  cpu: 100
  memory: 128
  ```
  CPU is given in millicores, and Memory is in megabytes.
* `public_uri` -- Optional. The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"
* `additional_iam_roles` -- Optional. A list of extra IAM role arns not captured by Opta which you wish to give to your service.


*Outputs*
* `docker_repo_url` -- The url of the docker repo created to host this app's images in this environment. Does not exist
when using external images.

#### External/Internal Image
Furthermore, this module supports deploying from an "external" image repository (currently only public ones supported)
by setting the `image` field to the repo (e.g. "kennethreitz/httpbin" in the examples). If you set the value to "AUTO" however,
it will automatically create a secure container repository with ECR on your account. You can then use the `opta push`
command to push to it!

#### Liveness/Readiness Probe
One of the benefits of K8s is that it comes with built in checks for the responsiveness of your server. These are called
[_liveness_ and _readiness_ probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).

tl;dr A liveness probe determines whether your server should be restarted, and readiness probe determines if traffic should
be sent to a replica or be temporarily rerouted to other replicas. Essentially smart healthchecks. Opta requires the
user to have such health check endpoints for all http apps (a hello world get endpoint would do) but for websockets it
just checks the tcp connection on the given port.

#### Autoscaling
As mentioned, autoscaling is available out of the box. We currently only support autoscaling
based on the pod's cpu and memory usage, but we hope to soon offer the ability to use 3rd party metrics like datadog
to scale. As mentioned in the k8s docs, the horizontal pod autoscaler (which is what we use) assumes a linear relationship between # of replicas
and cpu (twice the replicas means half expected cpu usage), which works well assuming low overhead.
The autoscaler then uses this logic to try and balance the cpu/memory usage at the percentage of request. So, for example,
if the target memory is 80% and we requested 100mb, then it'll try to keep the memory usage at 80mb. If it finds that
the average memory usage was 160mb, it would logically try to double the number of replicas.

#### Container Resources
One of the other benefits of kubernetes is that a user can have fine control over the [resources used by each of their containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
A user can control the cpu, memory and disk usage with which scheduling is made, and the max limit after which the container is killed.
With Opta, we expose such settings to the user, while keeping sensible defaults.

_NOTE_ We expose the resource requests and set the limits to twice the request values.

#### Ingress
You can control if and how you want to expose your app to the world! Check out
the [Ingress](/docs/tutorials/ingress) docs for more details.