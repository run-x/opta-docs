

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `sku_name` | The SKU of Azure Cache's Redis to use. `Basic`, `Standard` and `Premium`. | `standard` | False |
| `family` | The family/pricing group to use. Optionas are `C` for Basic/Standard and `P` for Premium. | `C` | False |
| `capacity` | The [size](https://azure.microsoft.com/en-us/pricing/details/cache/) (see the numbers following the C or P) of the Redis cache to deploy. | `2` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `cache_host` | The host through which to access the redis cache |