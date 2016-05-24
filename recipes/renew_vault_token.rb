# The first value here should only actually be used during testing
vault_token = data_bag_item('secrets', 'api_keys')[node.chef_environment]['vault']['default']

ruby_block 'renew vault token' do
  block do
    begin
      require 'net/http'

      # If this file exists, assume we're actually testing and use the token
      # from there instead. This is a hack to get around the order of attribute
      # writing operations.
      if File.exist? "#{Chef::Config[:file_cache_path]}/test-kitchen_test_token"
        vault_token = File.read "#{Chef::Config[:file_cache_path]}/test-kitchen_test_token"
      end

      vault_addr = node['etc_environment']['VAULT_ADDR']

      uri = URI "#{vault_addr}/v1/auth/token/renew-self"
      req = Net::HTTP::Post.new uri
      req['X-Vault-Token'] = vault_token
      req.content_type = 'application/json'
      response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request req }
      if response.code.to_i != 200
        raise "Bad response from vault server (#{vault_addr}): #{response.code}\n" \
              "Token: #{vault_token}\n" \
              "Body: #{response.body}\n"
      elsif JSON.parse(response.body)['auth']['client_token'] != vault_token
        # Hammond pointed out that the protocol leaves room for the client_token
        # to change upon renewal. Our setup doesn't handle that, so in the event
        # that it does occur, we bail.
        raise "HALP: client_token received from #{vault_addr} does not match " \
              'what we sent.'
      end
    rescue => e
      Chef::Log.error "Error renewing token with #{vault_addr}: #{e.message}"
      raise e
    end
  end
end
