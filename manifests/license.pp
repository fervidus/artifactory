# Install a license if neeeded
class artifactory::license {
  # Only run if Pro
  # or Hi Availablity
  if $::artifactory::is_pro or $::artifactory::is_ha {

    # for debug output on the puppet client
    #notify {"Running with \$mysql_server_id ${mysql_server_id} ID defined":}
    # for debug output on the puppet client - with full source information
    notify{"license: ${::artifactory::license_key}":}

    artifactory_license { "http://${::facts['ipaddress']}:8081/artifactory":
      ensure   => present,
      license  => $::artifactory::license_key,
      user     => 'admin',
      password => 'password',

    }
  }
}
