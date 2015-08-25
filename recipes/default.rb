#
# Cookbook Name:: et_secrets
# Recipe:: default
#
# Copyright (c) 2015 EverTrue, All Rights Reserved.

zk_hosts = search(:node,
                  "chef_environment:#{node.chef_environment} AND " \
                  'roles:zookeeper').map { |n| "#{n['fqdn']}:2181" }

node.set['vault']['config']['backend_options'] = {
  address: zk_hosts.join(','),
  advertise_addr: "http://#{node['fqdn']}:8200"
}

include_recipe 'hashicorp-vault::default'
