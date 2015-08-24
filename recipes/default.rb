#
# Cookbook Name:: et_secrets
# Recipe:: default
#
# Copyright (c) 2015 EverTrue, All Rights Reserved.

zk_hosts = search(:node,
                  "chef_environment:#{node.chef_environment} AND " \
                  'roles:zookeeper').map { "#{n['fqdn']}:2181" }

node.set['vault']['version'] = '0.2.0'
node.set['vault']['config']['backend'] = {
  zookeeper: {
    address: zk_hosts.join(','),
    advertise_addr: 'http://localhost:8200'
  }
}
node.set['vault']['config']['listener']['tcp']['tls_disable'] = 1
node.set['vault']['manage_certificate'] = false

directory File.dirname node['vault']['config_path']

include_recipe 'et_hashicorp-vault::default'
