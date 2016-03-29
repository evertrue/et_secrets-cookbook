ruby_block 'clear vault data store' do
  block do
    # require 'net/http'
    # require 'json'

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
    # require 'net/http'
    # require 'json'

    sleep 5

    # Re-initialize the vault
    http = Net::HTTP.new 'localhost', 8200
    req = Net::HTTP::Put.new '/v1/sys/init'
    req.body = { secret_shares: 1, secret_threshold: 1 }.to_json
    response = http.request req
    unseal_key = JSON.parse(response.body)['keys'].first

    # Unseal the vault
    req = Net::HTTP::Put.new '/v1/sys/unseal'
    req.body = { key: unseal_key }.to_json
    http.request req
  end
end
