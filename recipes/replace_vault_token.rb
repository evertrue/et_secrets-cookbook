replace_vault_token 'prod default' do
  token_name 'default'
  vault_host 'http://vault.service.prod-us-east-1.consul:8200'
  data_bag_name 'vault'
  data_bag_item_name 'tokens'
  options(
    ttl: '8670h',
    policies: %w(default apps)
  )
  top_level_key 'prod'
  min_remaining_ttl 3600
  accessor_token data_bag_item('vault', 'tokens')['prod']['vault']['worker_token']
end

replace_vault_token 'stage default' do
  token_name 'default'
  vault_host 'http://vault.service.stage-us-east-1.consul:8200'
  data_bag_name 'vault'
  data_bag_item_name 'tokens'
  options(
    ttl: '8670h',
    policies: %w(default apps)
  )
  top_level_key 'stage'
  min_remaining_ttl 3600
  accessor_token data_bag_item('vault', 'tokens')['stage']['vault']['worker_token']
end
