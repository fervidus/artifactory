# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {
  # Artifactory 7 introduced several breaking changes.
  # When no version number is specified, we have no choice but to guess.
  # Future versions of this module should enforce setting a version number.
  if ($artifactory::package_version =~ Enum['present','installed','latest']) {
    notify {'Specifying a version number in $artifactory::package_version is strongly recommended': loglevel => warning }
    $_legacy = true
  } elsif (versioncmp($artifactory::package_version, '7.0') >= 0) {
    $_legacy = false
  } else {
    # Default to legacy. This should ensure that we don't break old versions.
    $_legacy = true
  }

  # Evaluate file and directory locations
  if $_legacy {
    $_config_dir = "${::artifactory::artifactory_home}/etc"
    $_lib_dir = "${::artifactory::artifactory_home}/tomcat/lib"
    $_license_dir = "${::artifactory::artifactory_home}/etc"
    $_secrets_dir = "${::artifactory::artifactory_home}/etc/.secrets"
    $_security_dir = "${::artifactory::artifactory_home}/etc/security"
  } else {
    # Artifactory 7+
    $_config_dir = "${::artifactory::artifactory_home}/etc/artifactory"
    $_lib_dir = "${::artifactory::artifactory_home}/bootstrap/artifactory/tomcat/lib"
    $_license_dir = "${::artifactory::artifactory_home}/etc/artifactory"
    $_secrets_dir = "${::artifactory::artifactory_home}/etc/artifactory/.secrets"
    $_security_dir = "${::artifactory::artifactory_home}/etc/artifactory/security"
  }

  # Map binary provider types to their actual configuration options.
  $_types = {
    'filesystem' => 'file-system',
    'fullDb' => 'full-db',
    'cachedFS' => 'cache-fs',
    'fullDbDirect' => 'full-db-direct',
    's3' => 's3-storage-v3'
  }

  # Check if a value was provided that need to be replaced.
  if $::artifactory::binary_provider_type and $_types[$::artifactory::binary_provider_type] {
    $_binary_provider_type = $_types[$::artifactory::binary_provider_type]
  } else {
    # Use the option unmodified.
    $_binary_provider_type = $::artifactory::binary_provider_type
  }

  # Determine the base type of the binary provider by grouping similar
  # types. Required to determine the directory in the next step.
  case $_types[$::artifactory::binary_provider_type] {
    'file-system',
    'full-db',
    'cache-fs',
    's3': {
      $binary_provider_type = $_binary_provider_type
    }
    'full-db-direct': {
      $binary_provider_type = undef
    }
    default: {
      $binary_provider_type = 'file-system'
    }
  }

  # Determine the directory for the chosen binary provider.
  if ($binary_provider_type == 'file-system') and ! $::artifactory::binary_provider_filesystem_dir {
    if $::artifactory::binary_provider_base_data_dir {
      $binary_provider_filesystem_dir = "${::artifactory::binary_provider_base_data_dir}/filestore"
    } else {
      $binary_provider_filesystem_dir = undef
    }
  } elsif ($binary_provider_type == 'file-system') and $::artifactory::binary_provider_filesystem_dir {
    $binary_provider_filesystem_dir = $::artifactory::binary_provider_filesystem_dir
  } else {
    $binary_provider_filesystem_dir = undef
  }

  # Check if a DB configuration was provided.
  if ($::artifactory::db_url or
      $::artifactory::db_username or
      $::artifactory::db_password or
      $::artifactory::db_type) {

    # Check if all database parameters can be found.
    if ($::artifactory::db_url and
        $::artifactory::db_username and
        $::artifactory::db_password and
        $::artifactory::db_type) {

      # Download JDBC files.
      if ($::artifactory::jdbc_driver_url) {
        $file_name =  regsubst($::artifactory::jdbc_driver_url, '.+\/([^\/]+)$', '\1')

        file { "${_lib_dir}/${file_name}":
          source => $::artifactory::jdbc_driver_url,
          mode   => '0775',
          owner  => 'root',
        }
      }

      # Determine type of database.
      $db_driver = $::artifactory::db_type ? {
        'derby'      => 'org.apache.derby.jdbc.EmbeddedDriver',
        'mariadb'    => 'org.mariadb.jdbc.Driver',
        'mssql'      => 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
        'mysql'      => 'com.mysql.jdbc.Driver',
        'oracle'     => 'oracle.jdbc.OracleDriver',
        'postgresql' => 'org.postgresql.Driver',
        default      => 'not valid',
      }

      # Prepare options hash. Will later be used to setup DB configuration.
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
      # We only care to set values that have actually been defined.
      # Therefore remove empty ones from our collection.
      $_dbpropchanges = delete_undef_values($__dbpropchanges)

      # Pre-load secrets from a temporary file when starting up Artifctory.
      if $::artifactory::use_temp_db_secrets {
        file { $_secrets_dir:
          ensure => directory,
          owner  => $::artifactory::config_owner,
          group  => $::artifactory::config_group,
        }

        file { "${$_secrets_dir}/.temp.db.properties":
          ensure  => file,
          content => epp(
            'artifactory/db.properties.epp',
            {
              db_url                         => $::artifactory::db_url,
              db_username                    => $::artifactory::db_username,
              db_password                    => $::artifactory::db_password,
              db_type                        => $::artifactory::db_type,
              db_driver                      => $db_driver,
              binary_provider_type           => $binary_provider_type,
              pool_max_active                => $::artifactory::pool_max_active,
              pool_max_idle                  => $::artifactory::pool_max_idle,
              binary_provider_cache_maxsize  => $::artifactory::binary_provider_cache_maxsize,
              binary_provider_base_data_dir  => $::artifactory::binary_provider_base_data_dir,
              binary_provider_filesystem_dir => $binary_provider_filesystem_dir,
              binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
            }
          ),
          mode    => '0640',
          owner   => $::artifactory::config_owner,
          group   => $::artifactory::config_group,
        }

        # Setup a symlink for legacy versions.
        if $_legacy {
          file { "${::artifactory::artifactory_home}/etc/storage.properties":
            ensure => link,
            target => "${_secrets_dir}/.temp.db.properties",
          }
        }
      } else {
        # Check if we are working with a legacy version of Artifactory.
        if ($_legacy == false) {
          # Starting with Artifactory 7 the configuration is stored in YAML
          # format. However, these YAML files don't work with augeas, so there
          # is currently no way to implement the password-encryption-hack that
          # is used for legacy versions.
          # TODO: Manage system.yaml, especially the DB configuration.
        } else {
          # Make sure we have correct mode and ownership
          file { "${::artifactory::artifactory_home}/etc/db.properties":
            ensure => file,
            mode   => '0640',
            owner  => $::artifactory::config_owner,
            group  => $::artifactory::config_group,
          }
          file { "${::artifactory::artifactory_home}/etc/storage.properties":
            ensure => link,
            target => "${::artifactory::artifactory_home}/etc/db.properties",
          }

          # Prepare DB hash for use with Augeas.
          $dbpropchanges = $_dbpropchanges.reduce([]) | $memo, $value | {
          # lint:ignore:140chars
            $memo + "set \"${value[0]}\" \"${value[1]}\""
          # lint:endignore
          }

          # Setup database configuration in db.properties.
          augeas { 'db.properties':
            context => "/files${::artifactory::artifactory_home}/etc/db.properties",
            incl    => "${::artifactory::artifactory_home}/etc/db.properties",
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
            context => "/files${::artifactory::artifactory_home}/etc/db.properties",
            incl    => "${::artifactory::artifactory_home}/etc/db.properties",
            lens    => 'Properties.lns',
            changes => [ "set \"password\" \"${::artifactory::db_password}\"" ],
            onlyif  => "match /files${::artifactory::artifactory_home}/etc/db.properties/password size == 0",
            require => [Class['::artifactory::install']],
            notify  => Class['::artifactory::service'],
          }
        }
      }
    }
    else {
      # We are making an assumption that not passing db_username and db_password we are changing to derby
      # and do not need db.properties file, but least be explicit in cleaning up.
      if ($_legacy == true) and ($::artifactory::db_type == 'derby') {
        file { "${::artifactory::artifactory_home}/etc/db.properties":
          ensure  => absent,
        }
      }
      warning('Database port, hostname, username, password and type must be all be set, or not set. Install proceeding without DB configuration.')#lint:ignore:140chars
    }
  }

  # Configure the filestore.
  file { "${_config_dir}/binarystore.xml":
    ensure  => file,
    owner   => $::artifactory::config_owner,
    group   => $::artifactory::config_group,
    content => epp(
      'artifactory/binarystore.xml.epp',
      {
        binary_provider_type           => $_binary_provider_type,
        binary_provider_cache_maxsize  => $::artifactory::binary_provider_cache_maxsize,
        binary_provider_base_data_dir  => $::artifactory::binary_provider_base_data_dir,
        binary_provider_filesystem_dir => $binary_provider_filesystem_dir,
        binary_provider_cache_dir      => $::artifactory::binary_provider_cache_dir,
        binary_provider_config_hash    => $::artifactory::binary_provider_config_hash,
      }
    ),
    notify  => Class['artifactory::service'],
  }

  # Install master key.
  if ($::artifactory::master_key) {
    file { $_security_dir:
      ensure => directory,
      owner  => $::artifactory::config_owner,
      group  => $::artifactory::config_group,
    }

    file { "${_security_dir}/master.key":
      ensure  => file,
      content => $::artifactory::master_key,
      mode    => '0640',
      owner   => $::artifactory::config_owner,
      group   => $::artifactory::config_group,
      notify  => Class['artifactory::service'],
    }
  }

  # Install license key for commercial edition.
  if ($::artifactory::license_key) {
    file { "${_license_dir}/artifactory.lic":
      ensure  => file,
      content => $::artifactory::license_key,
      mode    => '0664',
    }
  }

  # Automatically setup the database server.
  if ($::artifactory::db_automate) and ($::artifactory::db_type == 'mysql') {
    include ::artifactory::mysql

    file_line { 'limits':
      ensure => present,
      path   => '/etc/security/limits.conf',
      line   => "artifactory soft nofile 32000 \n artifactory hard nofile 32000",
      notify => Class['artifactory::service'],
    }
    contain ::mysql::server
  }
}
