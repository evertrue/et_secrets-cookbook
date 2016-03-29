#
# Cookbook Name:: et_secrets
# Recipe:: default
#
# Copyright (c) 2015 EverTrue, All Rights Reserved.

include_recipe 'hashicorp-vault::default'
include_recipe 'et_consul::client'
