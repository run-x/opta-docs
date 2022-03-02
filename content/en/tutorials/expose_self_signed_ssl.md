---
title: "SSL without configuring DNS"
linkTitle: "SSL without configuring DNS"
date: 2022-02-28
draft: false
description: >
  Add a Secure SSL on Load Balancer without configuring DNS. 
---

Opta enables the capability to add Self Signed Certificates over their Load Balancers without the need of configuring a Cloudfront, or a Domain Name.

This enables testing SSL (with insecure mode) and helps to test features which require SSL like GRPC.

{{% alert title="Warning" color="warning" %}}
Note: Our Azure offering currently doesn't support Self Signed Certificates.
{{% /alert %}}

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

```bash
# Get the Load Balancer URL/IP based on the provider using the opta output command
export load_balancer=<load_balancer_url / load_balancer_ip>
```

```bash
# Testing without SSL
curl "http://$load_balancer/hello"
<p>Hello from Opta.!</p>
```

```bash
# Testing with SSL
curl "https://$load_balancer/hello" --insecure
<p>Hello from Opta.!</p>
```

```bash
# Get the certificate details
curl -vvI  "https://$load_balancer" --insecure
```


You can use this feature of Opta to create your own Services which may require using an SSL Certificate.
