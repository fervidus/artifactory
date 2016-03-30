# Install a license on pro if neeeded
class artifactory::license {
  # Only run if pro
  if $::artifactory::is_pro {
    exec { 'wait for service':
      path      => '/bin',
      #command   => "curl -uadmin:password -X POST -H 'Content-Type: application/json' -d '{\"licenseKey\": \"${::artifactory::license_key}\"}' http://localhost:8081/api/system/license",
      onlyif    => 'test `curl -sL -w "%{http_code}\\n" http://localhost:8081/api/system/license -o /dev/null` != \'200\'',
      tries     => 12,
      try_sleep => 10,
    }
  }
}
