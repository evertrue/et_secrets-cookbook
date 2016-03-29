package 'bind9'

service 'bind9' do
  supports status: true, restart: true, reload: true
  action   [:enable, :start]
end

%w(options local).each do |conf_file|
  cookbook_file "/etc/bind/named.conf.#{conf_file}" do
    notifies :restart, 'service[bind9]'
  end
end
