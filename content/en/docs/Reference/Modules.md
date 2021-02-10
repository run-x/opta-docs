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
and over for different users/environments. Opta yamls either directly or indeirectly (via macros) reference these constructs
under the `modules` field, of either the Layer's base


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
    uri_prefix: "/showoff"
    external_image: true
    env_vars:
      - name: APPENV
        value: prod
    links:
      database: []
      redis: []
  database: # This is an instance of the aws-rds module type called database
    type: aws-rds
  redis: # This is an instance of the aws-redis module type called redis
    type: aws-redis
```
or on the Layer's `blocks` fields.
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
Here is the list of module types for the user to use, with their inputs and outputs

## aws-acm-cert

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-dns

*Variables*
*

*Outputs*

## aws-documentdb

*Variables*
*

*Outputs*

## aws-eks-init

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-eks-nodegroup

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-network-init

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-rds

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-redis
This module create a redis cache via elasticache

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-s3-bucket

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## aws-state-init
This should be the first module of any env layer for AWS. It does the "base" setup for the account and state, including
setting up the service linked roles, state bucket, state lock table, and main kms key for all the standard account 
encryption needs.

*Variables*
* `bucket_name`: Name of bucket to use for [terraform state storage](https://www.terraform.io/docs/language/settings/backends/s3.html).
* `dynamodb_lock_table_name`: Name of the dynamodb lock table to use for state locking (i.e. stop simultaneous writes).

*Outputs*
* `state_bucket_id`: Name of state bucket.
* `state_bucket_arn`: Arn of the state bucket.
* `kms_account_key_arn`: Arn of the kms account key
* `kms_account_key_id`: Id of the kms account key (yeah sometimes they want the id, sometimes they want the arn lol)

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)

## datadog

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## ingress-nginx-init

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## k8s-cluster-autoscaler

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## k8s-external-dns

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


## k8s-metric-server

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)


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

Under the hood, it expects you to have [linkerd setup]({{< relref "#linkerd-init" >}}), which is taken care of for you
with the _init macro. With the service mesh set up, you app will be efficiently load balanced and reap all of the
lightweight service meshes [benefits](https://linkerd.io/2/features/).

tl;dr  
It deploys your service in kubernetes as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

*Variables*
* `port` -- Required. Specifies
* `replicas`
* `image`
* `tag`
* `env_vars`
* `secrets`
* `autoscaling_cpu_percentage_threshold`
* `autoscaling_mem_percentage_threshold`
* `liveness_probe_path`
* `readiness_probe_path`
* `pod_resource_requests`
* `domain`
* `uri_prefix`
* `iam_policy`


*Outputs*

## linkerd-init

*Variables*
*

*Outputs*

_Note_: part of the _init macro which is heavily recommended (i.e. use the _init macro and don't worry about this)
