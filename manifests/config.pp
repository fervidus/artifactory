# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {

  # Create the plugins directory
  file { $::artifactory::plugins_dir:
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
}
