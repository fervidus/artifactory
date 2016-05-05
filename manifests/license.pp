# Install a license if neeeded
class artifactory::license {
  # Only run if Pro
  # or Hi Availablity
  if $::artifactory::is_pro or $::artifactory::is_ha {
    artifactory_license { "http://${::facts['ipaddress']}:8081/artifactory":
      ensure   => present,
      license  => $::artifactory::license_key,
      user     => 'admin',
      password => 'password',
    }
  }
}
