# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {
  # Install storage.properties if Available
  if(
    $::artifactory::db_hostname or
    $::artifactory::db_port     or
    $::artifactory::db_username or
    $::artifactory::db_password or
    $::artifactory::db_type) {
    if (
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

      file { "${::artifactory::artifactory_home}/tomcat/lib/mysql-connector-java-5.1.39-bin.jar":
        ensure => file,
        source => 'puppet:///modules/artifactory/mysql-connector-java-5.1.39-bin.jar',
      }
    }
    else {
      warn('Database port, hostname, username, password and type must eithier all be set, or non-set. Install will proceed without configuring storage.')
    }
  }
}
