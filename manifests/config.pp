# == Class artifactory::config
#
# This class is called from artifactory for service config.
#
class artifactory::config {
  file { "${::artifactory::plugins_dir}/zip_upload.groovy":
    source  => 'puppet:///modules/artifactory/zip_upload.groovy',
    require => Package[$::artifactory::package_name],
    #notify  => Service['artifactory'],
  }
}
