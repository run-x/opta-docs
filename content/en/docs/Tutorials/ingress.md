---
title: "Ingress"
linkTitle: "Ingress"
date: 2020-02-01
description: >
  How to expose your app on the internet
---

### Setting the domain for an Environment
You can specify a domain for each environment which can be used by all 
the services running in that environment.

```yaml
meta:
  name: staging
  org_id: runx
  providers:
    aws:
      region: <region>
      allowed_account_ids: [ <account> ]
  variables:
    # Provide your domain here
    domain: "staging.startup.com"

_init: {}
```

Before opta can start using this domain name, you also need to update the domain's nameservers to point to AWS. This is how you do it:
- Run `opta apply` on the yaml file to create the underlying resources
- Run `opta output` and note down the nameservers that get printed. It's usually a set of 4 servers.
- Assuming you own startup.com and want to map staging.startup.com to this environment. Then you'd add the following NS records in your domain registrar, where ns1-ns4 are the nameservers from the previous step.
  ```
  staging				1h			ns1
  staging				1h			ns2
  staging				1h			ns3
  staging				1h			ns4
  ```
### Exposing a service

A service can be exposed on a subdomain of the environment domain or on a path.

#### Exposing on a subdomain

```yaml
meta:
  name: myapp 
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    domain: "myapp.{parent[domain]}"
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
    path: /myapp
    ...
```

Following the domain examples above, this will expose the service at https://staging.startup.com/myapp
