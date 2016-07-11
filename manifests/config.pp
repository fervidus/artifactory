# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {
  # Install storage.properties if Available
  if(
    $::artifactory::jdbc_driver_url or
    $::artifactory::db_hostname or
    $::artifactory::db_port     or
    $::artifactory::db_username or
    $::artifactory::db_password or
    $::artifactory::db_type) {
    if ($::artifatory::jdbc_driver_url and
        $::artifactory::db_hostname and
        $::artifactory::db_port     and
        $::artifactory::db_username and
        $::artifactory::db_password and
        $::artifactory::db_type
        ) {
      file { "${::artifactory::artifactory_home}/etc/storage.properties":
        ensure  => file,
        content => epp(
          'artifactory/storage.properties.epp',
          {
            db_port                        => $::artifactory::db_port,
            db_hostname                    => $::artifactory::db_hostname,
            db_username                    => $::artifactory::db_username,
            db_password                    => $::artifactory::db_password,
            db_type                        => $::artifactory::db_type,
            binary_provider_type           => $::artifactory::binaryvider_type,
            pool_max_active                => $::artifactory::pool_max_active,
            pool_max_idle                  => $::artifactory::pool_max_idle,
            binary_provider_cache_maxSize  => $::artifactory::binary_provider_cache_maxSize,
            binary_provider_filesystem_dir => $::artifactory::binary_provider_filesystem_dir,
            binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
          }
        ),
        mode    => '0664',
      }

      $file_name =  regsubst($::artifactory::jdbc_driver_url, '.+\/([^\/]+)$', '\1')

      staging::deploy { $file_name:
        target => "${::artifactory::artifactory_home}/tomcat/lib/${file_name}":
        source => $::artifactory::jdbc_driver_url,
      }
    }
    else {
      warning('Database port, hostname, username, password and type must eithier all be set, or non-set. Install will proceed without configuring storage.')
    }
  }
}
