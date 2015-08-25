#
# Cookbook Name:: et_secrets
# Spec:: default
#
# Copyright (c) 2015 EverTrue, All Rights Reserved.

require 'spec_helper'

describe 'et_secrets::default' do
  context 'when all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end
    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
