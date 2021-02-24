---
title: "Modules"
linkTitle: "Modules"
weight: 9
description: >
  Reference on the structure, input and output of different Modules
---

# What's an Opta module?

The heart of Opta is a set of "Modules" which basically map to AWS resources that
need to get created. Opta yamls reference these under the `modules` field.


```yaml
environments:
  - name: staging
    parent: "../env/opta.yml"
name: baloney
org_name: blah
modules:
  - name: app # This is an instance of the k8-service module type called app
    type: k8s-service
    port: 
      http: 80
    image: "kennethreitz/httpbin"
    public_uri: "dummy.{parent[domain]}/showoff"
    liveness_probe_path: "/get"
    readiness_probe_path: "/get"
    env_vars:
      - name: BLAH
        value: "{env}"
    links:
      - database  # Equivalent to database: []
      - redis  # Equivalent to redis: []
  - name: database # This is an instance of the aws-rds module type called database
    type: aws-rds
  - name: redis # This is an instance of the aws-redis module type called redis
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
strings representing resource permissions. For a shortcode, you can just write
the module name as a string, and we transform it to a map with the name as the
key and the value an empty list.
The module processor then transforms your module's input to intelligently
integrate your k8's service deployment to the now "linked" resources (described
in the next section).

```yaml
meta:
  parent: "../env/opta.yml"
  name: baloney
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
    bucket_name: "blah"
```

# Module Types
Here is the list of module types for the user to use, with their inputs and outputs:


## aws-base
This module is the "base" module for creating an environment in aws. It sets up the VPCs, default kms key and the
db/cache subnets. Defaults are set to work 99% of the time, assuming no funny networking constraints (you'll know them
if you have them), so _no need to set any of the fields or no what the outputs do_.

*Fields*
* `total_ipv4_cidr_block` -- Optional. This is the total cidr block for the VPC. Defaults to "10.0.0.0/16"
* `private_ipv4_cidr_blocks` -- Optional. These are the cidr blocks to use for the private subnets, one for each AZ. 
  Defaults to ["10.0.128.0/21", "10.0.136.0/21", "10.0.144.0/21"] 
* `public_ipv4_cidr_blocks` -- Optional. These are the cidr blocks to use for the public subnets, one for each AZ.
  Defaults to ["10.0.0.0/21", "10.0.8.0/21", "10.0.16.0/21"]

*Outputs*
* `kms_account_key_arn` -- The [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) of the default 
  [KMS](https://aws.amazon.com/kms/) key (this is what handles encryption for redis, documentdb, eks, etc...)
* `kms_account_key_id` -- The [ID](https://docs.aws.amazon.com/kms/latest/developerguide/find-cmk-id-arn.html) of the default 
  KMS key (sometimes things need the ID, sometimes the ARN, so we're giving both)
* `vpc_id` -- The ID of the [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) we created for 
  this environment
* `private_subnet_ids` -- The IDs of the private [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) 
  we setup for your environment
* `public_subnets_ids` -- The IDs of the public [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) 
  we setup for your environment

## aws-dns
This module creates a [Route53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) for 
your given domain. The [k8s-base]({{< relref "#k8s-base" >}}) module automatically hooks up the load balancer to it
for the domain and subdomain specified, but in order for this to actually receive traffic you will need to complete
the [dns setup](/docs/tutorials/ingress).

*Fields*
* domain -- Required. The domain you want (you will also get the subdomains for your use)

*Outputs*
* zone_id -- The ID of the hosted zone created
* name_servers -- The name servers of your hosted zone (very important for the dns setup)
* domain -- The domain again
* cert_arn -- The arn of the [ACM certificate ](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) which
  is used for ssl.

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

## aws-eks
This module creates an [EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html), and a default
nodegroup to host your applications in. This needs to be added in the environment opta yml if you wish to deploy services
as opta services run on Kubernetes (just EKS for now).

*Fields*
* `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
* `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
* `node_disk_size` -- Optional. The size of disk to give the nodes' ec2s. Defaults to 20(GB)
* `node_instance_type` -- Optional. The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. Defaults
  to t3.medium (highly unrecommended to set to smaller)
* `k8s_version` -- Optional. The Kubernetes version for the cluster. Must be [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)

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

## datadog
This module setups the [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/?tab=helm) integration onto
the EKS cluster created for this environment. Please read the [datadog tutorial](/docs/tutorials/datadog) for all the
details of the features.

*Fields*
None. It'll prompt the use for a valid api key the first time it's run, but nothing else, and nothing in the yaml.

*Outputs*
None

## k8s-base


## k8s-service
The most important module for deploying apps, k8s-service deploys a kubernetes app.
It deploys your service as a rolling update securely and with simple autoscaling right off the bat-- you
can even expose it to the world, complete with load balancing both internally and externally.

*Fields*
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
  cpu: "100m"
  memory: "128Mi"
  ```
* `public_uri` -- Optional. The full domain to expose your app under as well as path prefix. Must be the full parent domain or a subdomain referencing the parent as such: "dummy.{parent[domain]}/my/path/prefix"
* `additional_iam_roles` -- Optional. A list of extra IAM role arns not captured by Opta which you wish to give to your service.


*Outputs*
* `docker_repo_url` -- The url of the docker repo created to host this app's images in this environment. Does not exist
when using external images.

#### External/Internal Image
Furthermore, this module supports deploying from an "external" image repository (currently only public ones supported)
by setting the `image` field to the repo (e.g. "kennethreitz/httpbin" in the examples). If that's not set then
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

#### Ingress
You can control if and how you want to expose your app to the world! Check out
the [Ingress](/docs/tutorials/ingress) docs for more details.
