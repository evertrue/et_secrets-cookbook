%w(stage prod).each do |chef_env|
  replace_vault_token "#{chef_env} default" do
    token_name 'default'
    vault_host "http://vault.service.#{chef_env}-us-east-1.consul:8200"
    data_bag_name 'vault'
    data_bag_item_name 'tokens'
    options(
      ttl: '8670h',
      policies: %w(default apps)
    )
    top_level_key chef_env
    min_remaining_ttl 3600
    accessor_token data_bag_item('vault', 'tokens')[chef_env]['vault']['worker_token']
  end
end
