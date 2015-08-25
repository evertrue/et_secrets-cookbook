require 'spec_helper'

describe 'et_secrets::default' do
  context 'has a running instance of Vault' do
    describe service 'vault' do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'has the correct Vault config' do
    describe file '/home/vault/.vault.json' do
      describe '#content' do
        subject { super().content }
        it { is_expected.to match %r{"advertise_addr": "http://ip-(.+?).ec2.internal:8200"} }
        it do
          is_expected.to include 'dev-zookeeper-1.vagrantup.com:2181,' \
                                 'dev-zookeeper-2.vagrantup.com:2181'
        end
      end
    end
  end
end
