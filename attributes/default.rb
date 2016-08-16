set['hashicorp-vault']['config']['address'] = '0.0.0.0:8200'
set['hashicorp-vault']['config']['tls_disable'] = true
set['hashicorp-vault']['config']['backend_type'] = 'consul'
set['hashicorp-vault']['config']['default_lease_ttl'] = '720h' # 1 month
set['hashicorp-vault']['config']['max_lease_ttl'] = '8760h' # 1 year
set['hashicorp-vault']['manage_certificate'] = false

set['et_consul']['client']['definitions']['vault'] = {
  type: 'service',
  parameters: {
    port:  8200,
    tags: %w(vault http),
    check: {
      interval: '10s',
      timeout: '5s',
      http: 'http://127.0.0.1:8200/v1/sys/health'
    }
  }
}
