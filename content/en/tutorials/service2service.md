---
title: "Inter Service Communication"
linkTitle: "Inter Service Communication"
date: 2021-07-21
draft: false
description: >
  Communication between services
---

- All inter-communication is handled by the [Linkerd](https://linkerd.io/) service mesh. Linkerd provides mTLS, load balancing, retries and many other reliability/security features.

- Opta creates a private subnet where all the services run. So every service is inaccessible from the outside, by default. You can enable external requests by using the `public_uri` [field](/reference/aws/service_modules/aws-k8s-service).

- Every service also gets an internal-only domain name that can be used by other
  services to connect to it. The name is `<module-name>.<service-name>`. Requests
  sent to this domain will automatically get load balanced b/w all healthy
  containers.

For example, the following service, will be available at `app.hello-world` from any other service in the same environment.


```yaml
name: hello-world
environments:
  - name: staging
    path: "staging.yml"
modules:
  - name: app
    type: k8s-service
    port:
      http: 80
    image: AUTO
```
