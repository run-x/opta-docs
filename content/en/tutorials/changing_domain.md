---
title: "Changing Domains"
linkTitle: "Changing Domains"
date: 2021-11-15
draft: false
description: >
  How to change domains for your Opta environment.
---

Currently, Opta does not support multiple domains (except subdomains) per environment, although that may change
based on user demand. In order for a user to change the domain tied to their environment, they would need to
remove their current dns module, and then add a new one after applying. 

Take for example, if we had the current running environment:

```yaml
name: blah
org_name: baloney
providers:
  aws:
    region: us-east-1
    account_id: XXXXXXXXXXXX
modules:
  - type: base
  - type: dns
    domain: baloney.dev
  - type: k8s-cluster
  - type: k8s-base
```

Supposed we wished to change the domain to "otherdomain.dev". First we would remove the dns module:

```yaml
name: blah
org_name: baloney
providers:
  aws:
    region: us-east-1
    account_id: XXXXXXXXXXXX
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
```

Next we would `opta apply` the new yaml and see that the dns resources have been destroyed. 
**Note that your site will be temporarily offline after this step and before the next steps are completed.** 
Afterwards we would add the new dns module entry with the new domain like so:

```yaml
name: blah
org_name: baloney
providers:
  aws:
    region: us-east-1
    account_id: XXXXXXXXXXXX
modules:
  - type: base
  - type: dns
    domain: otherdomain.dev
  - type: k8s-cluster
  - type: k8s-base
```

We would opta apply like before and we would now have the new domain. Depending on your set up there may be some 
additional steps required:

### What if I had the domain delegated already?
That's fine, the removal of the old domain can proceed with no changes but at the end you would need to do the delegation
steps for the new domain.

### What if I had deployed some services whose public_uri was based off {parent.domain}?
You would need to do a new apply for each of those services as they would not have gotten the memo of the new domain.
You can use the same image, and opta yaml for the service as before-- zero change necessary, all we need is the
new apply.