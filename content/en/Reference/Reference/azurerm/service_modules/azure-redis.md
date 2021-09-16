

## Fields

- `sku_name` - Optional. The SKU of Azure Cache's Redis to use. `Basic`, `Standard` and `Premium`. Default standard
- `family` - Optional. The family/pricing group to use. Optionas are `C` for Basic/Standard and `P` for Premium. Default C
- `capacity` - Optional. The [size](https://azure.microsoft.com/en-us/pricing/details/cache/) (see the numbers following the C or P) of the Redis cache to deploy. Default 2

## Outputs

- cache_host - The host through which to access the redis cache