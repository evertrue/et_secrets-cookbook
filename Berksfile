source :chef_server
source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'et_consul'
  cookbook 'tiny_bind', path: "test/integration/cookbooks/tiny_bind"
  cookbook 'test_replace_vault_token', path: 'test/integration/cookbooks/test_replace_vault_token'
  cookbook 'test_deps', path: 'test/integration/cookbooks/test_deps'
end
