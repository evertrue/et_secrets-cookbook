# et_secrets [![Build Status](https://travis-ci.org/evertrue/et_secrets-cookbook.svg)](https://travis-ci.org/evertrue/et_secrets-cookbook)

Handles the installation and setup of various Evertrue-specific stuff related to secrets and Vault.

# Recipes

## default

Just a wrapper. Installs Vault and Consul client

## renew_vault_token

Renew the token at `data_bags: secrets/api_keys/#{ENV}/vault/default`

## replace_vault_token

Replace the token at `data_bags: secrets/api_keys/#{ENV}/vault/default` when its TTL reaches 3600 seconds. Possibly a complete replacement for `renew_vault_token`.

Short Description

**USE ONLY FOR TESTING!!!**

Completely re-initializes the vault at `http://localhost:8200`, generates a new root token, and saves it to `"#{Chef::Config[:file_cache_path]}/test-kitchen_root_token"`. Also generates a client token (for testing) and saves it to `"#{Chef::Config[:file_cache_path]}/test-kitchen_test_token"`. **ALL EXISTING VAULT DATA WILL BE ERASED!!!**

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
