#
# Cookbook Name:: et_secrets
# Resource:: replace_vault_token
#
# Copyright (c) 2016 EverTrue, All Rights Reserved.

resource_name :replace_vault_token
default_action :renew

property :token_name,               kind_of: String, name_attribute: true
# A full URL is expected for the vault host.
# E.g.
# http://localhost:8200
property :vault_host,
         kind_of: String,
         required: true,
         callbacks: { 'Must be a valid URL' => proc { |p| valid_url p } }
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

# Enable Pagerduty alerting when token is about to expire
property :pagerduty_key, kind_of: String

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

def self.valid_url(url)
  url =~ /\A#{URI.regexp(%w(http https))}\z/
end

def vault
  @vault ||= begin
    require 'vault'
    require 'pagerduty' if pagerduty_key

    v = Vault::Client.new address: vault_host, token: accessor_token
    if (ttl = v.auth_token.lookup_self.data[:ttl]) < (3_600 * 24 * 3) && ttl != 0
      Chef::Log.warn "The accessor token for #{token_name} expires in #{ttl} seconds"
      alert_token_expiring ttl if pagerduty_key
    end
    v
  end
end

def alert_token_expiring(ttl)
  msg = "The accessor token used for replacing #{token_name} expires in less than 3 days. " \
    'Please replace this token with a new one using the token/create API.'
  pd = Pagerduty.new pagerduty_key
  pd.trigger(
    msg,
    incident_key: "accessor token for #{token_name} expiring soon",
    client: node.name,
    details: {
      ttl: ttl
    }
  )
end

def new_token
  vault.auth_token.create options
end

def secret
  @secret ||= begin
    key_paths = %w(
      /etc/chef/encrypted_data_bag_secret
      /tmp/kitchen/encrypted_data_bag_secret
    )
    key_path = key_paths.find { |kp| ::File.exist? kp }
    ::File.read(key_path).chomp
  end
end

def data_bag_save(item_json)
  encrypted_new_item = Chef::EncryptedDataBagItem.encrypt_data_bag_item(item_json, secret)
  new_item = Chef::DataBagItem.from_hash(encrypted_new_item)
  new_item.data_bag(data_bag_name)
  new_item.save
end

action :renew do
  chef_gem 'vault'
  chef_gem 'pagerduty' if pagerduty_key
  db = data_bag_item(data_bag_name, data_bag_item_name).to_hash
  begin
    token_string = token_to_replace || db[top_level_key]['vault'][token_name]
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
    Chef::Log.debug(
      'Token does not exist, is invalid, or has expired. Requesting a new ' \
      "one with name #{token_name} and options: #{options.inspect}."
    )
    begin
      db[top_level_key]['vault'][token_name] = new_token.auth.client_token
    rescue => e
      Chef::Log.fatal "Value of auth: #{new_token.auth.inspect}"
      raise e
    end
    data_bag_save db
    new_resource.updated_by_last_action true
  else
    Chef::Log.debug 'Token exists and is not expired. Doing nothing.'
  end
end
