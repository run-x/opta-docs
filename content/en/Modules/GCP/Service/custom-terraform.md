---
title: "custom-terraform"
linkTitle: "custom-terraform"
date: 2021-07-21
draft: false
weight: 1
description: Allows a user to add their own terraform modules to opta
---

This module allows a user to add their own terraform modules to be included in opta. A user can use opta's interpolations
to even pass outputs to other modules into their custom one as inputs like:

```yaml
name: live-example-dev
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXXXXXXXXXX
modules:
  - type: base
  - type: custom-terraform
    path_to_module: "../blah_module"
    terraform_inputs:
      a: "${{module.base.vpc_id}}"
.
.
.
```

And then on the parent directory of the opta yaml there would be a `blah_module` directory/terraform yaml that has a main.tf
file like:
```hcl
variable "a" {
  type = string
}

resource "random_id" "blah" {
  byte_length = 8
  keepers = {
    a = var.a
  }
}

output "b" {
  value = "${var.a}-${random_id.blah.hex}"
}
```
### Fields

- `path_to_module` -- Required. A path to your terraform module relative to the opta yaml file.
- `terraform_inputs` -- Optional. Custom input to pass in to your terraform module.

### Outputs
None

