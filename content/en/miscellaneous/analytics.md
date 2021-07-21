---
title: "Analytics"
linkTitle: "Analytics"
date: 2021-07-21
draft: false
description: >
  Runx analytics on opta usage.
---

By default, opta executions send metrics and logs back to runx to gain intelligence of the product's usage, errors, and
to give superior support for the users. Like with the stdout users see, these reports do not hold ANY secrets or
passwords.

### Disable Reporting

We, however, understand and respect that some users may have strict privacy requirements and to support them we
have added the `OPTA_DISABLE_REPORTING` environment variable. If someone wishes to opt-out opta reporting, all they
have to do is set the aforementioned environment variable in the shell running opta
to some value like so:

```shell
export OPTA_DISABLE_REPORTING=1
```

Opta will then not send any metrics or logs back to runx in any subsequent calls.
