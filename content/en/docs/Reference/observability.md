---
title: "Observability Integrations"
linkTitle: "Observability Integrations"
date: 2020-02-01
description: >
  Configuring observability tool for your applications
---

Current Opta's observability tool of choice is Datadog. We will be adding support for more tools in near future. Reach out to us at support@runx.dev if you have a preference for which tool you would like to see here.

## Datadog
Opta makes it very easy to setup Datadog monitoring and logging for your applications. All you have to do is provide your Datadog api key during creation of the [environment](/docs/reference/environment_config).

Run the following command from the directory where your environment's `opta.yml` is present.
```bash
opta apply --var datadog_api_key={your_api_key}
```

This will setup datadog monitoring and logging on your kubernetes cluster. And now you can use datadog clients to send any metrics or use their APM directly in your app.
