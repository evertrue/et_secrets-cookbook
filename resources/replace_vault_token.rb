resource_name :replace_vault_token
default_action :renew

property :name,               kind_of: String, name_attribute: true
# A full URL is expected for the vault host.
# E.g.
# http://localhost:8200
property :vault_host,         kind_of: String, required: true
property :data_bag_name,      kind_of: String, required: true
property :data_bag_item_name, kind_of: String, required: true
property :options,            default: {}

# Manually specify the actual token to replace. Usually this is automatically
# gathered from the data bag key mentioned below, but this will override that
# value.
property :token_to_replace, kind_of: String

# The privileged token that will be used to request the new token
# requires the "create" capability on the "auth/token/create" path
property :accessor_token, kind_of: String, required: true

# The top level key for the path within the data bag for the token that
# is to be be replaced.

# e.g.
# {
#   "id": "your_data_bag",
#   "top_level_key": {
#     "vault": {
#       "default": "YOUR_OLD_KEY"
#     }
#   }
# }
property :top_level_key, kind_of: String, required: true

# If the existing token has more than this many seconds remaining before
# it expires, renewal will not take place. If unset, the token will be
# replaced every time.
property :min_remaining_ttl, kind_of: Integer

def vault
  @vault ||= begin
    require 'vault'

    v = Vault::Client.new address: vault_host, token: accessor_token
    return v unless (ttl = v.auth_token.lookup_self.data[:ttl]) < (3_600 * 24 * 3) &&
                    ttl != 0
    raise "My accessor token expires in #{ttl} seconds"
  end
end

def new_token
  vault.auth_token.create options
end

action :renew do
  chef_gem 'vault'
  db = data_bag_item(data_bag_name, data_bag_item_name)
  begin
    token_string = token_to_replace || db[top_level_key]['vault'][name]
    if token_string
      Chef::Log.debug 'Existing token found in data bags. Looking it up in Vault.'
      existing_token = vault.auth_token.lookup token_string
    end
  rescue Vault::HTTPClientError => e
    # Bad token indicates the token does not exist, which is fine for us; We'll
    # just set a new one.
    raise e unless e.message =~ /\* bad token/
    Chef::Log.warn 'Existing token is bad.'
  end

  # If:
  # - there is no existing token OR
  # - there's no minimum TTL OR
  # - there is a minimum TTL AND the token is below it
  # ... get a new token.
  if !existing_token ||
     !property_is_set?(:min_remaining_ttl) ||
     property_is_set?(:min_remaining_ttl) &&
     existing_token.data[:ttl] < min_remaining_ttl
    Chef::Log.debug 'Token does not exist, is invalid, or has expired. Requesting a new one.'
    db[top_level_key]['vault'][name] = new_token.auth[:client_token]
    db.save
    new_resource.updated_by_last_action true
  else
    Chef::Log.debug 'Token exists and is not expired. Doing nothing.'
  end
end
