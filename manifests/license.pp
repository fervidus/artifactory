# Install a license on pro if neeeded
class artifactory::license {
  # Only run if pro
  if $::artifactory::is_pro {
    artifactory_license { "http://${::facts['ipaddress']}:8081/artifactory":
      license  => 'ob',
      user     => 'admin',
      password => 'password',
    }
  }
}
