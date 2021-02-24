---
title: "Ingress"
linkTitle: "Ingress"
date: 2020-02-01
description: >
  How to expose your app on the internet
---

### Setting the domain for an Environment
With opta, you can specify a domain for each environment which can be used by all the services running in that 
environment. This is done with the aws-dns module like so:

```yaml
name: staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: aws-base
  - type: aws-dns # <-- this entry
    domain: staging.startup.com
  - type: aws-eks
  - type: k8s-base
```

As is, the aws-dns will create the "hosted zone" resource which you can think of as the object managing your dns rules
for the domain you listed. Technically, you can put any domain you wish (e.g. google.com), but in order for it to
receive public traffic and get ssl (to have https instead of http connections), you have to do some extra setup which
_proves_ that you own it.

This extra setup is updating the domain's nameservers to point to your opta environment's AWS "hosted zone". This is how you do it:
- Run `opta apply` on the yaml file at least once to create the underlying resources
- Run `opta output` and note down the nameservers that get printed. It's usually a set of 4 servers.
- Assuming you own startup.com and want to map staging.startup.com to this environment. Then you'd add the following NS records in your domain registrar, where ns1-ns4 are the nameservers from the previous step.
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

Once this is done and verified, please update your opta yaml aws-dns section to have a new field `delegated: true` like
so:

```yaml
name: staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: aws-base
  - type: aws-dns
    domain: staging.startup.com
    delegated: true # <-- THIS
  - type: aws-eks
  - type: k8s-base
```

Now run `opta apply` one more time and opta will now generate your ssl certificates and attach them. Congratulations,
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
    public_uri: "myapp.{parent.domain}/blah"
    ...
```

Following the domain examples above, this will expose the service at https://myapp.staging.startup.com/blah
