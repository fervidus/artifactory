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

  file { "${::artifactory::plugins_dir}/zip_upload.groovy":
    source  => 'puppet:///modules/artifactory/zip_upload.groovy',
    require => File[$::artifactory::plugins_dir],
    #notify  => Service['artifactory'],
  }

  # Make sure jdbc driver  
  file { "$::artifactory::jdbc_file":
    ensure => file,
    owner  => artifactory,
    group  => artifactory,
    require => Package[$::artifactory::package_name],
  }  

  # Make sure hanode 
  file { "$::artifactory::hanode_file":
    ensure => file,
    source  => 'puppet:///modules/artifactory/ha-node.properties',
    owner  => "artifactory",
    group  => "artifactory",
    mode   => '0664',
    require => Package[$::artifactory::package_name],
    #    notify  => Exec['edit_hanode0'],
  }

#  exec { "edit_hanode0":
#    command => "perl -pe 's/_node_id_/${::facts["hostname"]}/' $::artifactory::hanode_file",
#    #onlyif  => 
#    notify  => Exec['edit_hanode1'],
#  }
#
#  exec { "edit_hanode1":
#    command => "perl -pe 's/_cluster_home_/${::artifactory::cluster_home}/' ${::artifactory::hanode_file}",
#    #onlyif  => 
#    notify  => Exec['edit_hanode2'],
#  }
#
#  exec { "edit_hanode2":
#    command => "perl -pe 's/_ip_address_/${::facts["ip_address"]}/' ${::artifactory::hanode_file}",
#    #onlyif  => 
#  }

}
