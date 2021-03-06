# et_secrets CHANGELOG

This is the Changelog for the et_secrets cookbook.

## [Unreleased][unreleased]

### Changes

### Fixes

## v4.0.1 - (2016-09-30)

### Fixes

* Do not allow automatic reboots (moved from the `et_consul` cookbook where it didn't belong)

## v4.0.0 - (2016-08-16)

### Breaking

* Bump et_consul to 4.0

## v3.0.0 - (2016-08-16)

### Breaking

* Pin hashicorp-vault cookbook at exactly v2.4.0 (Includes [some breaking changes](https://www.vaultproject.io/docs/install/upgrade-to-0.6.html))

### Changes

* Set default lease ttl to 1 year
* Don't pin specific vault version (Allows Vault version to rise to 0.6.0)

## v2.3.2 - (2016-07-07)

### Changes

* Test that encrypted data bag insertion occurred with an actual encrypted data bag

### Fixes

* Encrypted data bag save: Convert source data bag item to hash earlier in the process

## v2.3.1 - (2016-07-07)

### Fixes

* Fix saving of encrypted data bag

## v2.3.0 - (2016-07-07)

### Changes

* Alert PD before token expires

## v2.2.2 - (2016-06-06)

### Fixes

* Allow replacement token name to be different than replace_vault_token resource name
* Move vault tokens to a separate data bag location to deal with lack of source control

## v2.2.1 - (2016-06-03)

### Fixes

* Replace data_bag_name/data_bag_item

## v2.2.0 - (2016-06-03)

### Changes

* New recipe and resource: replace_vault_token
* Set global max and default lease TTLs

## v2.1.2 - (2016-05-24)

### Fixes

* Pass ALL of the arguments to fetch on redirect

## v2.1.1 - (2016-05-24)

### Fixes

* Handle redirects from vault server
* No illegal characters in name tags

## v2.1.0 - (2016-05-24)

### Changes

* New recipe: `renew_vault_token`
* Make vault_init a regular recipe (rather than a test cookbook) so that other cookbooks can use it

### Fixes

* Include et_consul dependency (already in use in et_secrets::default)
* Use sftp transport for test kitchen
* Use "mocking" instead of "bootstrap_expect" to set bootstrap expect number for consul

## v2.0.1 - (2016-04-14)

### Fixes

* Drop specifying `address` in Vault Consul Service definition
    - Fixes how the Consul DNS works and provides the correct private IP for Vault

## v2.0.0 - (2016-04-04)

### Changes

* Migrate Vault code from et_consul back into here
* Upgrade to Vault 0.5.2, which is breaking due to various changes
* Use `hashicorp-vault ~> 2.1`

## v1.0.0 - (2015-09-03)

### Changes

* Bumping to v1.0.0 to reflect introduction to prod
* Add Vault policies as JSON files, though they are not yet used by this cookbook for anything

## v0.2.0 - (2015-08-25)

### Changes

* Switch to using as-yet-unreleased version of the official `hashicorp-vault` cookbook, instead of our fork (which likely will wither & die)
* Add integration test for `advertise_addr`

## v0.1.1 - (2015-08-25)

### Fixes

* Set Vault to listen on `0.0.0.0:8200`, allowing outside traffic

## v0.1.0 - (2015-08-25)

### Added

* Initial release
