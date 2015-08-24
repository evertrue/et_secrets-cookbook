name             'et_secrets'
maintainer       'EverTrue'
maintainer_email 'devops@evertrue.com'
license          'all_rights'
description      'Installs/Configures et_secrets'
long_description 'Installs/Configures et_secrets'
version          '0.2.0'

supports 'ubuntu', '>= 14.04'

depends 'hashicorp-vault'
depends 'certificate', '~> 0.5'
