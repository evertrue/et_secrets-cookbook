require 'spec_helper'
require 'json'
require 'net/http'
require 'vault'

describe 'et_secrets::default' do
  context 'has a running instance of Vault' do
    describe service 'vault' do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'has the correct Vault config' do
    describe file '/etc/vault/vault.json' do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include '"tls_disable": "true"' }
        it { is_expected.to include '"max_lease_ttl": "8760h"' }
        it { is_expected.to include '"default_lease_ttl": "720h"' }
        it { is_expected.to match(/"backend": {\s+"consul"/) }
      end
    end
  end

  describe 'Responses' do
    let(:resolv) { Resolv::DNS.new nameserver_port: %w(127.0.0.1) }
    let(:my_ip) do
      Socket.ip_address_list.find { |intf| intf.ipv4? && !intf.ipv4_loopback? }.ip_address
    end

    it 'Vault is unsealed' do
      expect(
        JSON.parse(Net::HTTP.get(URI('http://localhost:8200/v1/sys/seal-status')))['sealed']
      ).to eq false
    end

    it 'Consul can resolve Vault with DNS' do
      expect(resolv.getaddress('vault.service.consul.').to_s == my_ip)
    end
  end
end

describe 'test_replace_vault_token::default' do
  let(:vault) do
    tries = 15
    until Net::HTTP.get_response(URI('http://127.0.0.1:8200/v1/sys/health')).code.to_i == 200 ||
          tries == 0
      # Vault doesn't start up right away. This waits for it to do so.
      sleep 1
      tries -= 1
    end
    data_bag_item = JSON.parse(File.read('/tmp/kitchen/data_bags/vault/tokens.json'))
    accessor_token = data_bag_item['dev']['vault']['new_token_2']
    Vault::Client.new address: 'http://localhost:8200', token: accessor_token
  end

  sleep 20

  it 'generates and saves a valid token' do
    expect(vault.auth_token.lookup_self.data[:creation_ttl]).to eq 31_212_000
  end
end
