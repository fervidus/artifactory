# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {

  # Create the plugins directory
  file { "$::artifactory::plugins_dir":
    ensure => directory,
    owner  => artifactory,
    group  => artifactory,
    require => Package[$::artifactory::package_name],
  }

  ## TODO: Put back notify #notify  => Service['artifactory'],
  file { "${::artifactory::plugins_dir}/zip_upload.groovy":
    source  => 'puppet:///modules/artifactory/zip_upload.groovy',
    require => File[$::artifactory::plugins_dir],
  }

  # Make sure jdbc driver  
  file { "$::artifactory::jdbc_file":
    ensure  => file,
    owner   => artifactory,
    group   => artifactory,
    source  => 'puppet:///modules/artifactory/ojdbc7.jar',
    require => Package[$::artifactory::package_name],
  }

  if ( $::artifactory::is_ha )  {
    # Make sure hanode 
    file { "$::artifactory::hanode_file":
      ensure => file,
      #source  => 'puppet:///modules/artifactory/ha-node.properties',
      content => epp('artifactory/ha-node.properties.epp', 
        {'clusterhome'     => $::artifactory::clusterhome, 
         'artifactory_nic' => $::artifactory::artifactory_nic,
         'is_primary'      => $::artifactory::is_primary,
         'membership_port' => $::artifcatory::membership_port,
        }),
      owner  => "artifactory",
      group  => "artifactory",
      mode   => '0664',
      require => Package[$::artifactory::package_name],
    }
    file { '/var/opt/jfrog/artifactory/etc/storage.properties':
      ensure    => file,
      content => epp('artifactory/oracle.properties.epp', 
        {'oracle_url'     => $::artifactory::oracle_url, 
         'db_user'        => $::artifactory::db_user,
         'db_password'    => $::artifactory::db_password,
        }),
      owner  => "artifactory",
      group  => "artifactory",
      mode   => '0664',
      require => Package[$::artifactory::package_name],
    }
  }


  }
