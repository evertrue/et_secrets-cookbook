node.set['vault']['version'] = '0.2.0'
node.set['vault']['config']['listener']['tcp']['address'] = '0.0.0.0:8200'
node.set['vault']['config']['listener']['tcp']['tls_disable'] = 1
node.set['vault']['manage_certificate'] = false
