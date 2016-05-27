require 'spec_helper'
require 'json'
require 'net/http'

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
