# Install a license on pro if neeeded
class artifactory::license {
  # Only run if pro
  if $::artifactory::is_pro {
    exec { 'wait for service':
      path      => '/bin',
      #command   => $wait_command,
      onlyif    => 'test -z `curl --silent --show-error --connect-timeout 1 -I http://localhost:8081 | grep Coyote | cut -d : -f 2`',
      tries     => 12,
      try_sleep => 10,
    }
  }
}
