source :chef_server
source 'https://supermarket.chef.io'

metadata

group :integration do
  %w(vault_init tiny_bind).each do |cb|
    cookbook cb, path: "test/integration/cookbooks/#{cb}"
  end

  cookbook 'et_consul'
end
