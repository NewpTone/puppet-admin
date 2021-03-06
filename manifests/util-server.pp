# This class defines the basics of a 'util' server.
# It has more roles than this, but the other roles
# rely on storedconfigs so it can't be bootstrapped
# without storedconfigs set up

class admin::util-server (
  $mysql_root_password,
  $puppet_dashboard_user,
  $puppet_dashboard_password,
  $puppet_dashboard_site,
  $puppet_storeconfigs_password,
  $cobbler_dhcp_start_range,
  $cobbler_dhcp_stop_range,
  $cobbler_next_server,
  $cobbler_server,
  $postfix_my_networks,
) {

  # Set up the puppetmaster server
  class { 'admin::puppet-master':
    puppet_storeconfigs_password => $puppet_storeconfigs_password,
    puppet_dashboard_user        => $puppet_dashboard_user,
    puppet_dashboard_password    => $puppet_dashboard_password,
    puppet_dashboard_site        => $puppet_dashboard_site,
  }

  # Set up cobbler
  class { 'admin::cobbler':
    next_server      => $cobbler_next_server,
    server           => $cobbler_server,
    dhcp_start_range => $cobbler_dhcp_start_range,
    dhcp_stop_range  => $cobbler_dhcp_stop_range,
  }

  # Set up apt-cacher
  class { 'admin::apt-cacher-ng::server': }

  # Set up MySQL server
  class { 'mysql::server':
    config_hash => {
      'root_password' => $mysql_root_password,
      'bind_address' => '0.0.0.0',
    }
  }
  class { 'mysql::server::account_security': }

  # Set up Postfix - allow outgoing mail from network
  class { 'admin::mail::postfix':
    my_networks => $postfix_my_networks,
  }

  # Make sure the default docroot is still in place
  apache::vhost { "default-${::params::util_public_hostname}":
    priority   => '1',
    servername => $public_hostname,
    port       => '80',
    docroot    => '/var/www',
    log_name   => $::admin::params::util_public_hostname,
  }

  apache::vhost { "default-ssl-${::params::util_public_hostname}":
    priority   => '1',
    servername => $public_hostname,
    ssl        => true,
    port       => 443,
    docroot    => '/var/www',
    log_name   => $::admin::params::util_public_hostname,
  }
}
