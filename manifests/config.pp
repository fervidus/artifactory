# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {
  # Install storage.properties if Available
  if(
    $::artifactory::db_url or
    $::artifactory::db_username or
    $::artifactory::db_password or
    $::artifactory::db_type) {
    if ($::artifactory::db_url and
        $::artifactory::db_username and
        $::artifactory::db_password and
        $::artifactory::db_type
        ) {

      file { "${::artifactory::artifactory_home}/etc/.secrets":
        ensure => directory,
        owner  => 'artifactory',
        group  => 'artifactory',
      }

      file { "${::artifactory::artifactory_home}/etc/.secrets/.temp.db.properties":
        ensure  => file,
        content => epp(
          'artifactory/db.properties.epp',
          {
            db_url                         => $::artifactory::db_url,
            db_username                    => $::artifactory::db_username,
            db_password                    => $::artifactory::db_password,
            db_type                        => $::artifactory::db_type,
            binary_provider_type           => $::artifactory::binary_provider_type,
            pool_max_active                => $::artifactory::pool_max_active,
            pool_max_idle                  => $::artifactory::pool_max_idle,
            binary_provider_cache_maxsize  => $::artifactory::binary_provider_cache_maxsize,
            binary_provider_base_data_dir  => $::artifactory::binary_provider_base_data_dir,
            binary_provider_filesystem_dir => $::artifactory::binary_provider_filesystem_dir,
            binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
          }
        ),
        mode    => '0640',
        owner   => 'artifactory',
        group   => 'artifactory',
      }

      file { "${::artifactory::artifactory_home}/etc/storage.properties":
        ensure => link,
        target => "${::artifactory::artifactory_home}/etc/db.properties",
      }

      if ($::artifactory::jdbc_driver_url) {
        $file_name =  regsubst($::artifactory::jdbc_driver_url, '.+\/([^\/]+)$', '\1')

        file { "${::artifactory::artifactory_home}/tomcat/lib/${file_name}":
          source => $::artifactory::jdbc_driver_url,
          mode   => '0775',
          owner  => 'artifactory',
        }
      }
    }
    else {
      warning('Database port, hostname, username, password and type must be all be set, or not set. Install proceeding without DB configuration.')
    }
  }

  file { "${::artifactory::artifactory_home}/etc/binarystore.xml":
    ensure  => file,
    content => epp(
      'artifactory/binarystore.xml.epp',
      {
        binary_provider_type           => $::artifactory::binary_provider_type,
        binary_provider_cache_maxsize  => $::artifactory::binary_provider_cache_maxsize,
        binary_provider_base_data_dir  => $::artifactory::binary_provider_base_data_dir,
        binary_provider_filesystem_dir => $::artifactory::binary_provider_filesystem_dir,
        binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
      }
    ),
  }

  if ($::artifactory::master_key) {
    file { "${::artifactory::artifactory_home}/etc/security":
      ensure => directory,
      owner  => 'artifactory',
      group  => 'artifactory',
    }

    file { "${::artifactory::artifactory_home}/etc/security/master.key":
      ensure  => file,
      content => $::artifactory::master_key,
      mode    => '0640',
      owner   => 'artifactory',
      group   => 'artifactory',
    }
  }
}
