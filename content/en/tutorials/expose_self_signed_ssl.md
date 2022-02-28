---
title: "SSL without configuring DNS"
linkTitle: "SSL without configuring DNS"
date: 2022-02-28
draft: false
description: >
  Add a Secure SSL on Load Balancer without configuring DNS. 
---

Opta gives its users the capability to add Self Signed Certificates over their Load Balancers without the need of configuring a Cloudfront, or a Domain Name.

Some reasons could be that the Technology the user wants to test requires an SSL connection, such as a GRPC service, or use secure connections for the Inter-service communications.

***Note: Our Azure offering currently doesn't support Self Signed Certificates.***

### How to expose a Secure Port

With Opta configurations, just set the `expose_self_signed_ssl` flag as `true` with the k8s-base ([AWS](/reference/aws/environment_modules/aws-k8s-base)/[GCP](/reference/google/environment_modules/gcp-k8s-base)) opta module.

{{< tabs tabTotal="3" >}}
{{< tab tabName="Aws" >}}

{{< highlight yaml "hl_lines=9-12" >}}
# env.yaml
name: staging
org_name: my-org
providers:
  aws:
    region: us-east-1
    account_id: XXXX # Your 12 digit AWS account id
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
    expose_self_signed_ssl: true
{{< / highlight >}}

{{< /tab >}}
{{< tab tabName="Gcp" >}}

{{< highlight yaml "hl_lines=9-12" >}}
# env.yaml
name: staging
org_name: my-org
providers:
  google:
    region: us-central1
    project: XXXX # Your GCP Project name
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
    expose_self_signed_ssl: true
{{< / highlight >}}

{{< /tab >}}
{{< tab tabName="Hello_Opta" >}}

{{< highlight yaml "hl_lines=9-12" >}}
# hello-opta.yaml
name: hello
environments:
  - name: staging
    path: "env.yaml" # the file we created in previous step
modules:
  - type: k8s-service
    name: hello
    port:
      http: 80
    # from https://github.com/run-x/hello-opta
    image: ghcr.io/run-x/hello-opta/hello-opta:main
    healthcheck_path: "/"
    # path on the load balancer to access this service
    public_uri: "/hello"
{{< / highlight >}}

{{< /tab >}}
{{< /tabs >}}

The above configurations will help expose the Secure Port for accessing the Hello Opta service.

<figure>
<img src="/images/insecure-hello-opta.png">
<figcaption align = "center">Fig. 1: Hello-Opta service called without SSL Certificate</figcaption>
</figure>

<figure>
<img src="/images/secure-hello-opta.png">
<figcaption align = "center">Fig. 2: Hello-Opta service called without SSL Certificate</figcaption>
</figure>

<figure>
<img src="/images/ssl-certificate.png">
<figcaption align = "center">Fig. 3: Generated Certificate</figcaption>
</figure>


You can use this feature of Opta to create your own Services which may require using an SSL Certificate.