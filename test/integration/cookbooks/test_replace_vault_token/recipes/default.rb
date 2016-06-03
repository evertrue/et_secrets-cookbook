replace_vault_token 'new_token' do
  vault_host 'http://localhost:8200'
  data_bag_name 'secrets'
  data_bag_item_name 'api_keys'
  options(
    ttl: '8670h',
    policies: %w(default)
  )
  top_level_key node.chef_environment
  # Sadly, because of order-of-operations reasons here, in order to see the
  # min_remaining_ttl function actually do its thing, we have to pass the token
  # in directly, rather than reading it from a data bag item the way it's likely
  # to work "in real life."
  #
  # Consequently, since this token will not appear to be expired, the "new_token"
  # key in the test data bag will not be written out, so we won't be able to
  # validate it in our ServerSpec tests.
  token_to_replace(lazy do
    File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_test_token"
  end)
  min_remaining_ttl 3600
  accessor_token(lazy do
    File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_root_token"
  end)
end

replace_vault_token 'new_token_2' do
  vault_host 'http://localhost:8200'
  data_bag_name 'secrets'
  data_bag_item_name 'api_keys'
  options(
    ttl: '8670h',
    policies: %w(default)
  )
  top_level_key node.chef_environment
  accessor_token(lazy do
    File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_root_token"
  end)
end
