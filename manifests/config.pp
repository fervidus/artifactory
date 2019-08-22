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
      if $::artifactory::use_temp_db_secrets {
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
          target => "${::artifactory::artifactory_home}/etc/.secrets/.temp.db.properties",
        }

      } else {
        # Make sure we have correct mode and ownership
        file { "${::artifactory::artifactory_home}/etc/db.properties":
          ensure  => file,
          mode    => '0640',
          owner   => 'artifactory',
          group   => 'artifactory',
        }
        file { "${::artifactory::artifactory_home}/etc/storage.properties":
          ensure => link,
          target => "${::artifactory::artifactory_home}/etc/db.properties",
        }

        $db_driver = $::artifactory::db_type ? {
          'derby'      => 'org.apache.derby.jdbc.EmbeddedDriver',
          'mssql'      => 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
          'mysql'      => 'com.mysql.jdbc.Driver',
          'oracle'     => 'oracle.jdbc.OracleDriver',
          'postgresql' => 'org.postgresql.Driver',
          default      => 'not valid',
        }

        # Following logic in templates/db.properties.epp
        case $::artifactory::binary_provider_type {
          'filesystem',
          'fullDb',
          'cachedFS': {
            $binary_provider_type = $::artifactory::binary_provider_type
          }
          'fullDbDirect': {
            $binary_provider_type = undef
          }
          default: {
            $binary_provider_type = 'filesystem'
          }
        }

        # Following logic in templates/db.properties.epp
        if $binary_provider_type == 'filesystem' and ! $::artifactory::binary_provider_filesystem_dir {
            $mapped_provider_filesystem_dir = 'filestore'
        } else {
            $mapped_provider_filesystem_dir = $::artifactory::binary_provider_filesystem_dir
        }
        if $::artifactory::binary_provider_base_data_dir {
          $binary_provider_filesystem_dir = "${::artifactory::binary_provider_base_data_dir}/${mapped_provider_filesystem_dir}"
        }else{
          $binary_provider_filesystem_dir = undef
        }

        $__dbpropchanges = {
          'type'                           => $::artifactory::db_type,
          'url'                            => $::artifactory::db_url,
          'driver'                         => $db_driver,
          'username'                       => $::artifactory::db_username,
          'binary.provider.type'           => $binary_provider_type,
          'pool.max.active'                => $::artifactory::pool_max_active,
          'pool.max.idle'                  => $::artifactory::pool_max_idle,
          'binary.provider.cache.maxsize'  => $::artifactory::binary_provider_cache_maxsize,
          'binary.provider.filesystem.dir' => $binary_provider_filesystem_dir,
          'binary.provider.cache_dir'      => $::artifactory::binary_provider_cache_dir,
        }
        # We only care to set values that have actually be defined.
        # Therefore empty ones from our collection
        $_dbpropchanges = delete_undef_values($__dbpropchanges)
        $dbpropchanges = $_dbpropchanges.reduce([]) | $memo, $value | {
        # lint:ignore:140chars
          $memo + "set \"${value[0]}\" \"${value[1]}\""
        # lint:endignore
        }
        augeas { 'db.properties':
          context => '/files/var/opt/jfrog/artifactory/etc/db.properties',
          incl    => '/var/opt/jfrog/artifactory/etc/db.properties',
          lens    => 'Properties.lns',
          changes => $dbpropchanges,
          require => [Class['::artifactory::install']],
          notify  => Class['::artifactory::service'],
        }

        # We treat db_password differently
        # Artifactory likes to encrypt the password after starting.
        # Onlyif statement will allow us to set password if the password
        # has not be set yet, else it is not touched.
        # To update password from hiera, remove the password field in db.properties,
        # to update locally, just update and Artifactory will encrypt.
        augeas { 'db.properties.pw':
          context => '/files/var/opt/jfrog/artifactory/etc/db.properties',
          incl    => '/var/opt/jfrog/artifactory/etc/db.properties',
          lens    => 'Properties.lns',
          changes => [ "set \"password\" \"$::artifactory::db_password\"" ],
          onlyif  => 'match /files/var/opt/jfrog/artifactory/etc/db.properties/password size == 0',
          require => [Class['::artifactory::install']],
          notify  => Class['::artifactory::service'],
        }

      }

      if ($::artifactory::jdbc_driver_url) {
        $file_name =  regsubst($::artifactory::jdbc_driver_url, '.+\/([^\/]+)$', '\1')

        file { "${::artifactory::artifactory_home}/tomcat/lib/${file_name}":
          source => $::artifactory::jdbc_driver_url,
          mode   => '0775',
          owner  => 'root',
        }
      }
    }
    else {
      # We are making an assumption that not passing db_username and db_password we are changing to derby
      # and do not need db.properties file, but least be explicit in cleaning up.
      if $::artifactory::db_type == 'derby' {
        file { "${::artifactory::artifactory_home}/etc/db.properties":
          ensure  => absent,
        }
      }
      warning('Database port, hostname, username, password and type must be all be set, or not set. Install proceeding without DB configuration.')#lint:ignore:140chars
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

  if ($::artifactory::db_automate) and ($::artifactory::db_type == 'mysql') {
    include systemd::systemctl::daemon_reload
    include ::artifactory::mysql

    file { 'artif_service':
      ensure => present,
      path   => '/lib/systemd/system/artifactory.service',
      source => 'puppet:///modules/artifactory/artifactory.service',
      mode   => '0755',
    }
    file_line { 'limits':
      ensure => present,
      path   => '/etc/security/limits.conf',
      line   => "artifactory soft nofile 32000 \n artifactory hard nofile 32000",
    }
    file { 'artifManage':
      ensure => present,
      path   => '/opt/jfrog/artifactory/bin/artifactoryManage.sh',
      source => 'puppet:///modules/artifactory/artifactoryManage.sh',
      mode   => '0775',
    }
    ~> Class['systemd::systemctl::daemon_reload']
    contain ::mysql::server
  }
}
