ruby_block 'generate test worker token' do
  block do
    root_token = File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_root_token"
    req = Net::HTTP::Post.new '/v1/auth/token/create'
    req['X-Vault-Token'] = root_token
    req.body = { display_name: 'test', policies: %w(root), ttl: '1h' }.to_json
    http = Net::HTTP.new 'localhost', 8200
    response = http.request req

    unless response.code.to_i == 200
      raise "ERROR: Got response #{response.code} from vault during " \
            "short lived worker token generation.\n" \
            "Root token: #{root_token}\n" \
            "Body: #{response.body}"
    end

    parsed_response = JSON.parse(response.body)

    File.open("#{Chef::Config[:file_cache_path]}/test-kitchen_short_lived_worker_token", 'w') do |f|
      f.write parsed_response['auth']['client_token']
    end
  end
end

replace_vault_token 'expiring accessor token' do
  token_name 'new_token_3'
  vault_host 'http://localhost:8200'
  data_bag_name 'vault'
  data_bag_item_name 'tokens'
  options(
    policies: %w(default)
  )
  top_level_key node.chef_environment
  accessor_token(lazy do
    File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_short_lived_worker_token"
  end)
end

replace_vault_token 'non-expired test token' do
  token_name 'new_token'
  vault_host 'http://localhost:8200'
  data_bag_name 'vault'
  data_bag_item_name 'tokens'
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

replace_vault_token 'replace every time test token' do
  token_name 'new_token_2'
  vault_host 'http://localhost:8200'
  data_bag_name 'vault'
  data_bag_item_name 'tokens'
  options(
    ttl: '8670h',
    policies: %w(default)
  )
  top_level_key node.chef_environment
  accessor_token(lazy do
    File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_root_token"
  end)
end
