---
title: "redis"
linkTitle: "redis"
date: 2021-07-21
draft: false
description: Creates a redis cache via Azure Cache
---

This module creates a redis cache via [Azure Cache](https://azure.microsoft.com/en-us/services/cache/).
It is made with their standard high availability offering, but (unlike in AWS) there is no
[encryption at rest](https://techcommunity.microsoft.com/t5/azure-paas-blog/encryption-on-azure-cache-for-redis/ba-p/1800449),
but encryption in-traffic is enforced. It is made in the with [private link](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-private-link)
ensuring private communication.

### Fields

- `sku_name` -- The SKU of Azure Cache's Redis to use. `Basic`, `Standard` and `Premium`. Defaults to Standard
- `family` -- The family/pricing group to use. Optionas are `C` for Basic/Standard and `P` for Premium. Defaults to C
- `capacity` -- The [size](https://azure.microsoft.com/en-us/pricing/details/cache/) (see the numbers following the C or P)
  of the Redis cache to deploy. Defaults to 2

### Linking

When linked to a k8s-service, it adds connection credentials to your container's environment variables

- `{module_name}_cache_auth_token` -- The auth token/password of the cluster.
- `{module_name}_cache_host` -- The host to contact to access the cluster.

In the [modules reference](/modules-reference), the _{module_name}_ would be replaced with `cache`

The permission list can optionally have one entry which should be a map for renaming the default environment variable
names to a user-defined value:

```yaml
links:
  - db:
      - cache_host: CACHEHOST
        cache_auth_token: CACHEPASS
```

If present, this map must have renames for all 2 fields.

### NOTE

Unliked in GCP and AWS, Azure's Redis port is 6380, rather than 6379
