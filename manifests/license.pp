# Install a license on pro if neeeded
class artifactory::license {
  # Only run if pro
  if $::artifactory::is_pro {
    artifactory_license { "http://${::facts['ipaddress']}:8081/artifactory":
      ensure   => present,
      license  => $::artifactory::license_key,
      user     => 'admin',
      password => 'password',
    }
  }
}
