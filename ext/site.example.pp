include admin::functions
include admin::params
include admin::params::cloud

# Configure filebucket backup
filebucket { "main":
    server => $::admin::params::private_hostname,
    path => false,
}

File { backup => main }

import 'nodes.pp'
