# et_secrets [![Build Status](https://travis-ci.org/evertrue/et_secrets-cookbook.svg)](https://travis-ci.org/evertrue/et_secrets-cookbook)

TODO: Enter the cookbook description here.

# Requirements

* `apt` cookbook
* `some` cookbook
* `another` cookbook


# Recipes

## default

## replace_vault_token

Replace the token at `data_bags: secrets/api_keys/#{ENV}/vault/default` when its TTL reaches 3600 seconds. Possibly a complete replacement for `renew_vault_token`.

Short Description

1. Set up & updates apt using `apt::default`
2. Install xyz by some proccess
3. Include various recipes for this cookbook:
    * `et_secrets::install`
        - which includes `et_secrets::another`
    * `et_secrets::configure`

## renew_vault_token

This recipe renews the Vault token contained in the `secrets/api_keys` data bag item by calling `/auth/tokens/renew-self` on the Vault API. It requires `node['etc_environment']['VAULT_ADDR']` to be set.

## vault_init

Used only during testing. Re-initializes the vault to a like-new state, unseals it and populates `node['et_secrets']['test_token']` with a test token with default privileges.

Never (**ever, ever**) put this recipe in the run list on a real server!!!

# Resources

## replace_vault_token

```ruby
replace_vault_token 'default' do
  vault_host "http://vault.service.#{node.chef_environment}-us-east-1.consul:8200"
  data_bag_name 'secrets'
  data_bag_item_name 'api_keys'
  options(
    ttl: '8670h',
    policies: %w(default apps)
  )
  top_level_key node.chef_environment
  min_remaining_ttl 3600
  accessor_token data_bag_name('secrets', 'api_keys')[node.chef_environment]['vault']['worker_token']
end
```

#### Properties

* **name** - The name associated with the token in the data bag and in the Vault server metadata.
* **vault_host** - Self explanatory. E.g. `http://vault.host:8200`
* **options** - A hash passed verbatim to the Vault token-create API. E.g. `{ policies: ['default', 'apps'] }`
* **token_to_replace** - A string containing the actual token to replace. If provided, the resource will verify this token against the Vault API instead of trying to use a token from the data bag. If a new token is generated (because the specified token is expired or invalid) it will still be stored in the specified data bag.
* **accessor_token** - The token to use for processing the request (See **Required Permissions**)
* **min_remaining_ttl** - If the existing token has less than this many seconds remaining on its TTL, it will be replaced. If unspecified, a new token will be generated each time the resource is run.
* **data_bag_name** and **data_bag_item_name** - Where to find and store the token.
* **top_level_key** - The top level key for the path within the data bag for the token that is to be be replaced. E.g.
```json
{
  "id": "your_data_bag",
  "top_level_key": {
    "vault": {
      "default": "YOUR_OLD_KEY"
    }
  }
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests with `kitchen test`, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Author:: EverTrue (devops@evertrue.com)
