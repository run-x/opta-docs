---
title: "Modules"
linkTitle: "Modules"
weight: 9
description: >
  Reference on the structure, input and output of different Modules
---

# What's an opta module?

The heart of Opta is a set of "Modules" which are our wrapper over [terraform modules](https://www.terraform.io/docs/language/modules/index.html).
Just like regular software libraries/packages, our modules are groups of distinct resources which we want to create over
and over for different users/environments. Opta yamls either directly or indirectly (via macros) reference these constructs
under the `modules` field, of either the Layer's base as follows:


```yaml
meta:
  parent: "../env/opta.yml"
  name: baloney
modules:
  app: # This is an instance of the k8-service module type called app
    type: k8s-service
    target_port: 80
    image: "kennethreitz/httpbin"
    tag: "latest"
    domain: "dummy.{parent[domain]}"
    liveness_probe_path: "/get"
    readiness_probe_path: "/get"
    path_prefix: "/showoff"
    external_image: true
    env_vars:
      - name: BLAH
        value: malarkey
    links:
      database: []
      redis: []
  database: # This is an instance of the aws-rds module type called database
    type: aws-rds
  redis: # This is an instance of the aws-redis module type called redis
    type: aws-redis
```
Or on the Layer's `blocks` fields, as follows:
```yaml
meta:
  parent: "../env/opta.yml"
  name: baloney
blocks:
  - modules: # This block holds 2 modules, named linkerd, datadog
      linkerd:
        type: linkerd-init
      datadog:
        type: datadog
        api_key: "{datadog_api_key}"
  - modules: # This block holds one module of type k8s-hello-world-service named hello
      hello:
        type: k8s-hello-world-service
        hello_world_domain: "hello-world.{domain}"
```
You'll note that the module instance can have user-specified names which will come into play later with references.

## Variables
You'll note that there can be many, varying, fields per module instance such as "type", "env_vars", "api_key" etc... 
These are called _variables_ and this is how specific data passed into the

### Types
All modules have their own list of supported variables, but the one common to all is _type_. The type variable is simply
the module reference (e.g. the library/package to use in this "import"). Opta currently comes with its list of valid
modules built in -- future work may allow users to specify their own.

## Outputs and References
To pass data along the chain to new resources created in the same block or succeeding blocks, modules often have output
fields (e.g. the database password, the vpc id, the K8s api endpoint, etc...). These field can be referenced directly
or indirectly

## Directly
Currently, a module can reference the outputs of another in its variable by passing it as a string wrapped in ${{}} 
```yaml
...
          aws-eks-init:
            type: aws-eks-init
            cluster_name: main
            subnet_ids: "${{module.aws-network-init.private_subnet_ids}}"
            key_arn: "${{module.aws-state-init.kms_account_key_arn}}"
```

## Indirectly
### Inheritance
For convenience's sake, the outputs of the parent layer are passed to the child and any variable in the child's module
with the same name as the output will get it automatically. For instance, the elasticache redis instances we create
are all encrypted at rest. In order to do this we need a KMS key arn which we setup for you via the _init macro which
you should run to setup your base environment. Because the variable is called kms_account_key_arn, and the output is
also called kms_account_key_arn, if you have the base environment setup as the parent, then you never need to think
about it yourself.
```yaml
meta:
  parent: "../env/opta.yml" # Parent has kms_account_key_arn
  name: baloney
modules:
  redis:
    # invisible kms_account_key_arn reference added here
    type: aws-redis
```


### Linking
The k8s-service module type is the first (but not the last) module to support special processing. In this case, it's
in regard to the _links_ variable. The links variable takes as input a map where the key is the name of another
module in the layer (not in a future block) and the value a list of strings representing resource manipulation 
permissions (e.g. IAM permissions wrappers). The module processor then transforms your module's input to intelligently
integrate your k8's service deployment to the now "linked" resources.
```yaml
meta:
  parent: "../env/opta.yml"
  name: baloney
modules:
  app: # This is an instance of the k8-service module type called app
.
.
.
    links:
      database: []
      redis: []
      doc_db: []
      bucket:
        - write
  database: # This is an instance of the aws-rds module type called database
    type: aws-rds
  redis: # This is an instance of the aws-redis module type called redis
    type: aws-redis
  doc_db:
    type: aws-documentdb
    name: test-docdb
  bucket:
    type: aws-s3-bucket
    bucket_name: "blah"
```

This intelligent integration is supported for the following module types:

#### aws-rds
An aws-rds link adds secrets to your deployment for the database name, user, password, and host, which are added to your
container as _{module_name}\_db\_user_, _{module_name}\_db\_password_, _{module_name}\_db\_name_, and _{module_name}\_db\_host_.
The permission list is to be empty because we currently do not support giving apps IAM permissions to manipulate a database
and that should not come up for +95% of the use cases (these permissions mean modifying the database itself, like 
destroying it or increasing its size, which an app should not concern itself with).

#### aws-redis
An aws-redis link adds secrets to your deployment for the redis cache host, and auth-token (password) which are added to your
container as _{module_name}\_cache\_host_ and _{module_name}\_cache\_auth\_token_.
The permission list is to be empty because we currently do not support giving apps IAM permissions to manipulate a redis cache
and that should not come up for +95% of the use cases (these permissions mean modifying the cache itself, like
destroying it or increasing its size, which an app should not concern itself with).

#### aws-documentdb
tl;dr same as aws-rds, but no db_name

An aws-documentdb link adds secrets to your deployment for the database user, password, and host, which are added to your
container as _{module_name}\_db\_user_, _{module_name}\_db\_password_, and _{module_name}\_db\_host_.
The permission list is to be empty because we currently do not support giving apps IAM permissions to manipulate a database
and that should not come up for +95% of the use cases (these permissions mean modifying the database itself, like
destroying it or increasing its size, which an app should not concern itself with).

#### aws-s3
An aws-s3 link adds the necessary IAM permissions to read (e.g. list objects and get objects) and write (e.g. list, get,
create, destroy, and update objects) to the given s3 bucket. The current permissions are (wait for it), "read" and "write"

# Current Module Types
Here is the list of module types for the user to use, with their inputs and outputs:


## aws-documentdb
This module creates an AWS Documentdb  cluster. It is made in the private subnets created by the _init
macro and so can only be accessed in the VPC or through some proxy (e.g. VPN). It is encrypted
at rest with a kms key created in the env setup via the _init macro and in transit via tls.

*Variables*
* `instance_class` -- Optional. This is the RDS instance type used for the documentdb cluster [instances](https://aws.amazon.com/documentdb/pricing/).
  Default db.r5.large

*Outputs*
* `db_user` -- DB user
* `db_password` -- DB password
* `db_host` -- DB host

_NOTE_ For documentdb to work with SSL encryption (and password authentication requires that), it needs to fetch the
[SSL certificates and have them ready in the local machine](https://docs.aws.amazon.com/documentdb/latest/developerguide/connect_programmatically.html).
Fortunately, the opta k8s-service module has already taken care of that. You'll find them at `/config/rds_ca.pem"`

## aws-rds
This module creates a postgres Aurora RDS database instance. It is made in the private subnets created by the _init 
macro and so can only be accessed in the VPC or through some proxy (e.g. VPN).

*Variables*
* `instance_class` -- Optional. This is the RDS instance type used for the Auror cluster [instances](https://aws.amazon.com/rds/instance-types/).
  Default db.r5.large
* `engine_version` -- Optional. The version of the database to use. Default 11.9.

*Outputs*
* `db_user` -- DB user
* `db_password` -- DB password
* `db_host` -- DB host
* `db_name` -- DB name

## aws-redis
This module creates a redis cache via elasticache. It is made with one failover instance across azs, and is encrypted
at rest with a kms key created in the env setup via the _init macro and in transit via tls. It is made in the private
subnets created by the _init macro and so can only be accessed in the VPC or through some proxy (e.g. VPN).

*Variables*
* `node_type` -- Optional. This is the redis instance type used for the [instances](https://aws.amazon.com/elasticache/pricing/). 
  Default cache.m4.large.

*Outputs*
* `cache_auth_token` -- The auth token/password of the cluster.
* `cache_host` -- The host to contact to access the cluster.


_NOTE_ Redis CLI will not work against this cluster because redis cli does not support the TLS transit encryption. There
should be no trouble with any of the language sdks however, and they should all support ssl enabled.

## aws-s3-bucket
This module creates an S3 bucket for storage purposes. It is created with server-side AES256 encryption.

*Variables*
* `bucket_name`-- Required. The name of the bucket to create.
* `block_public` -- Optional. Block all public access. Default true
* `bucket_policy` -- Optional. A custom s3 policy json/yaml to add.

*Outputs*
* `bucket_id` -- The id/name of the bucket.
* `bucket_arn` -- The arn of the bucket.

## k8s-service
The most import module for deploying apps, k8s-service deploys a k8s app into your EKS cluster as a [helm chart](https://helm.sh/docs/topics/charts/).

It creates the following for you in K8s:
* A [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) just for your app's resources.
  The namespace name will be the name of the layer.
* A [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) with your app's containers.
* A [service](https://kubernetes.io/docs/concepts/services-networking/service/) for your deployment.
  The service name will be the name of the module
* A [secret](https://kubernetes.io/docs/concepts/configuration/secret/) holding your sensitive key-value pairs. This is
  different than standard envars because they're encrypted in the K8s state storage and is hidden in the k8s api.
* A [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) which maps
  to an iam role special to this app (aws sdks will work from the start)
* A [horizontal pod autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to scale up
  your containers depending on cpu and memory usage.
* Optionally, an [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to expose your app to the
  world if you set a domain.

Under the hood, it expects you to have linkerd setup, which is taken care of for you
with the _init macro. With the service mesh set up, you app will be efficiently load balanced and reap all of the
lightweight service meshes [benefits](https://linkerd.io/2/features/).

tl;dr  
It deploys your service in kubernetes as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

#### External/Internal Image
Furthermore, this module supports deploying from an "external" image repository (currently only public ones supported)
by setting the `image` variable to the repo (e.g. "kennethreitz/httpbin" in the examples). If that's not set then
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
As mentioned, autoscaling is handled by the official Horizontal Pod Autoscaler. We currently only support autoscaling
based on the pod's cpu and memory usage, but we hope to soon offer the ability to use 3rd party metrics like datadog
to scale. As mentioned in the k8s docs, the horizontal pod autoscaler assumes a linear relationship between # of replicas
and cpu (twice the replicas means half expected cpu usage), which works well assuming low overhead.
The autoscaler then uses this logic to try and balance the cpu/memory usage at the percentage of request. So, for example,
if the target memory is 80% and we requested 100mb, then it'll try to keep the memory usage at 80mb. If it finds that
the average memory usage was 160mb, it would logically try to double the number of replicas.

#### Container Resources
One of the other benefits of kubernetes is that a user can have fine control over the [resources used by each of their containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
A user can control the cpu, memory and disk usage with which scheduling is made, and the max limit after which the container is killed.
With opta, we expose such settings to the user, while keeping sensible defaults.

#### Ingress
Yet another benefit of K8s is a standardized form of exposing your app to the world via ingress and api gateways. Our
environment _init macro adds the [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/) to the K8s
clusters. This ingress is bound to a Network Load Balancer which is in turn bound to the hosted zone created by the same 
macro. Assuming that the nameservers where delegated properly, traffic should be coming into your cluster automatically.
The ingress can then be used to control where the traffic flows depending on host and path_prefix among other fields
to be supported in the future by opta.

*Variables*
* `port` -- Required. Specifies what port your app was made to be listened to. Currently it must be a map of the form
  `http: [PORT_NUMBER_HERE]` or `tcp: [PORT_NUMBER_HERE]`. Use http if you just have a vanilla http server and tcp for
  websockets.
* `min_autoscaling` -- Optional. The minimum number of replicas your app can autoscale to. Default 1
* `max_autoscaling` -- Optional. The maximum number of replicas your app can autoscale to. Default 3
* `image` -- Optional. If you specify this, then it will use the image specified for its deploys and not make an ECR
  repo itself.
* `tag` -- Optional, use this if you are using an internal image whose repo is managed by the module. The tag specifies
  what image tag to pull from the image repo. We recommend tagging based on git commit sha
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
* `container_resource_limits` -- Optional. See the [container resources]({{< relref "#container-resources" >}}) section. Default
  ```yaml
  cpu: "200m"
  memory: "256Mi"
  ```
* `container_resource_requests` -- Optional. See the [container resources]({{< relref "#container-resources" >}}) section. Default
  ```yaml
  cpu: "100"
  memory: "128"
  ```
* `public_uri` -- Optional. The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"
* `additional_iam_roles` -- Optional. A list of extra IAM role arns not captured by opta which you wish to give to your service.


*Outputs*
* `docker_repo_url` -- The url of the docker repo created to host this app's images in this environment. Does not exist
when using external images.
