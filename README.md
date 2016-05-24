# et_secrets [![Build Status](https://travis-ci.org/evertrue/et_secrets-cookbook.svg)](https://travis-ci.org/evertrue/et_secrets-cookbook)

TODO: Enter the cookbook description here.

# Requirements

* `apt` cookbook
* `some` cookbook
* `another` cookbook


# Recipes

## default

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

# Usage

Include this recipe in a wrapper cookbook:

```
depends 'et_secrets', '~> 1.0'
```

```
include_recipe 'et_secrets::default'
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
