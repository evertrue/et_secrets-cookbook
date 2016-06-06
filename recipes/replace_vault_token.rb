replace_vault_token 'default' do
  vault_host "http://vault.service.#{node.chef_environment}-us-east-1.consul:8200"
  data_bag_name 'vault'
  data_bag_item_name 'tokens'
  options(
    ttl: '8670h',
    policies: %w(default apps)
  )
  top_level_key node.chef_environment
  min_remaining_ttl 3600
  accessor_token data_bag_item('vault', 'tokens')[node.chef_environment]['vault']['worker_token']
end
