---
title: "Ingress"
linkTitle: "Ingress"
date: 2021-07-21
description: >
  How to expose your app on the internet
---

### Setting the domain for an Environment

With Opta, you can specify a domain for each environment which can be used by all the services running in that
environment. This is done with the aws-dns/gcp-dns module like so:
{{< tabs tabTotal="2" tabID="1" tabName1="AWS" tabName2="GCP" >}}
{{< tab tabNum="1" >}}

```yaml
name: aws-staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: base
  - type: dns # <-- this entry
    domain: staging.startup.com
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< tab tabNum="2" >}}

```yaml
name: gcp-staging
org_name: runx
providers:
  google:
    region: us-central1
    project: jds-throwaway-1
modules:
  - type: base
  - type: dns # <-- this entry
    domain: staging.example.com
    subdomains:
      - myapp
    delegated: false
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< /tabs >}}

As is, the dns module will create the "hosted zone" resource which manages your dns rules
for the domain you listed. In order for it to receive public traffic and get ssl
(to have https instead of http connections), you have to do some extra setup which
_proves_ that you own it.

This extra setup is updating the domain's nameservers to point to your Opta environment's AWS/GCP "hosted zone". This is how you do it:

- Run `opta apply` on the yaml file at least once to create the underlying resources
- Run `opta output` and note down the nameservers that get printed. It's usually a set of 4 servers.
- Assuming you own example.com and want to map staging.example.com to this environment. Then you'd add the following NS records in your domain registrar, where ns1-ns4 are the nameservers from the previous step.
  ```
  staging				1h			ns1
  staging				1h			ns2
  staging				1h			ns3
  staging				1h			ns4
  ```

It will take a few minutes for this change to sync with the internet, so just go and grab some coffee for 10 minutes.

You can verify that you did this properly by running this command:

```shell
dig staging.startup.com NS
```

You should see your name servers under the `ANSWER SECTION` part.

Once this is done and verified, please update your Opta yaml aws-dns/gcp-dns section to have a new field `delegated: true` like
so:
{{< tabs tabTotal="2" tabID="2" tabName1="AWS" tabName2="GCP" >}}
{{< tab tabNum="1" >}}

```yaml
name: aws-staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: base
  - type: dns
    domain: staging.startup.com
    delegated: true # <-- THIS
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< tab tabNum="2" >}}

```yaml
name: gcp-staging
org_name: runx
providers:
  google:
    region: us-central1
    project: jds-throwaway-1
modules:
  - type: base
  - type: dns
    domain: staging.example.com
    subdomains:
      - myapp
    delegated: true # <-- THIS
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< /tabs >}}

Now run `opta apply` one more time and Opta will now generate your ssl certificates and attach them. Congratulations,
your environment will now be picking up public traffic on your domain and have https!

### Exposing a service

A service can be exposed on a subdomain of the environment domain or on a path via the public_uri field.

#### Exposing on a subdomain

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    public_uri: "myapp.{parent.domain}"
    ...
```

Following the domain examples above, this will expose the service at https://myapp.staging.startup.com

#### Exposing on a path

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    public_uri: "{parent.domain}/myapp"
    ...
```

Following the domain examples above, this will expose the service at https://staging.startup.com/myapp

### Combine both

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    public_uri: "myapp.{parent.domain}/v1"
    ...
```

Following the domain examples above, this will expose the service at https://myapp.staging.startup.com/v1
