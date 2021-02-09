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
  providers:
    aws:
      region: <region>
      allowed_account_ids: [ <account> ]
  variables:
    # Provide your domain here
    domain: "staging.startup.com"

_init: {}
```

Before opta can start using this domain, you also need to delegate the domain's nameservers to AWS.

Let's say you own startup.com and want to map staging.startup.com to this environment. Then you'd add the following NS records in your domain registrar:
```
staging				1h			ns-1053.awsdns-03.org.
staging				1h			ns-1557.awsdns-02.co.uk.
staging				1h			ns-914.awsdns-50.net.
staging				1h			ns-145.awsdns-18.com.
```

### Exposing a service

A service can be exposed on a subdomain of the environment domain or on a path.

#### Exposing on a subdomain

```yaml
meta:
  name: my_app 
  envs:
    - parent: "staging/opta.yml"
modules:
  - my_app:
      type: k8s-service
      domain: "my_app.{parent[domain]}"
      ...
```

Following the domain examples above, this will expose the service at https://my_app.staging.startup.com


#### Exposing on a path

```yaml
meta:
  name: my_app 
  envs:
    - parent: "staging/opta.yml"
modules:
  - my_app:
      type: k8s-service
      path: /my_app
      ...
```

Following the domain examples above, this will expose the service at https://staging.startup.com/my_app
