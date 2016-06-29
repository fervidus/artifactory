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
    $::artifactory::db_type
    ) {
    file { '/var/opt/jfrog/artifactory/etc/storage.properties':
      ensure  => file,
      content => epp(
        'artifactory/oracle.properties.epp',
        {
          db_url                         => $::artifactory::db_url,
          db_username                    => $::artifactory::db_username,
          db_password                    => $::artifactory::db_password,
          db_type                        => $::artifactory::db_type,
          binary_provider_type           => $::artifactory::binaryvider_type,
          pool_max_active                => $::artifactory::pool_max_active,
          pool_max_idle                  => $::artifactory::pool_max_idle,
          binary_provider_cache_maxSize  => $::artifactory::binaryvider_cache_maxSize,
          binary_provider_filesystem_dir => $::artifactory::binaryvider_filesystem_dir,
          binary_provider_cache_dir      => $::artifactory::binaryvider_cache_dir,
        }
      ),
      mode    => '0664',
    }
  }
}
