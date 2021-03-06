name             'et_secrets'
maintainer       'EverTrue'
maintainer_email 'devops@evertrue.com'
license          'all_rights'
description      'Installs/Configures et_secrets'
long_description 'Installs/Configures et_secrets'
version          '4.0.2'

supports 'ubuntu', '>= 14.04'

depends 'hashicorp-vault', '= 2.4.0'
depends 'et_consul', '~> 4.0'
