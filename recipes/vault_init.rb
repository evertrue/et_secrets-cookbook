ruby_block 'clear vault data store' do
  block do
    # Clear the Vault data store (from Consul)
    uri = URI('http://localhost:8500/v1/kv/vault?recurse')
    req = Net::HTTP::Delete.new uri
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request req }
  end
end

execute 'restart vault' do
  command 'service vault restart'
end

ruby_block 're-initialize and unseal vault' do
  block do
    sleep 5

    # Re-initialize the vault
    http = Net::HTTP.new 'localhost', 8200
    req = Net::HTTP::Put.new '/v1/sys/init'
    req.body = { secret_shares: 1, secret_threshold: 1 }.to_json
    response = http.request req

    unless response.code.to_i == 200
      raise "ERROR: Got response #{response.code} from vault during " \
            "re-initialization. Body: #{response.body}"
    end

    parsed_response = JSON.parse(response.body)
    unseal_key = parsed_response['keys'].first
    root_token = parsed_response['root_token']

    File.open("#{Chef::Config[:file_cache_path]}/test-kitchen_root_token", 'w') do |f|
      f.write root_token
    end

    # Unseal the vault
    req = Net::HTTP::Put.new '/v1/sys/unseal'
    req.body = { key: unseal_key }.to_json
    response = http.request req

    unless response.code.to_i == 200
      raise "ERROR: Got response #{response.code} from vault during " \
            "unsealing. Body: #{response.body}"
    end

    sleep 5

    req = Net::HTTP::Post.new '/v1/auth/token/create'
    req['X-Vault-Token'] = root_token
    req.body = { display_name: 'test', policies: %w(default), ttl: '1000h' }.to_json
    response = http.request req

    unless response.code.to_i == 200
      raise "ERROR: Got response #{response.code} from vault during " \
            "test token generation.\n" \
            "Root token: #{root_token}\n" \
            "Body: #{response.body}"
    end

    parsed_response = JSON.parse(response.body)

    unless parsed_response['auth']['lease_duration'] == 3_600_000
      raise "Test token TTL was not long enough: #{parsed_response['auth']['lease_duration']}"
    end

    File.open("#{Chef::Config[:file_cache_path]}/test-kitchen_test_token", 'w') do |f|
      f.write parsed_response['auth']['client_token']
    end
  end
end
