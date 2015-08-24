require 'spec_helper'

describe 'et_secrets::default' do
  context 'has a running instance of Vault' do
    describe service 'vault' do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
