# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::install {
  # The YUM repos change based on whether or not installing pro
  if $::artifactory::is_pro {
    $yum_name = 'bintray-jfrog-artifactory-pro-rpms'
    $yum_baseurl = 'https://jfrog.bintray.com/artifactory-pro-rpms'
  }
  else {
    $yum_name = 'bintraybintray-jfrog-artifactory-rpms'
    $yum_baseurl = 'bintraybintray-jfrog-artifactory-rpms'
  }

  # Add the jfrog yum repo
  yumrepo { $yum_name:
    baseurl  => $yum_baseurl,
    descr    => $yum_name,
    gpgcheck => 0,
    enabled  => 1,
  }

  package { $::artifactory::package_name:
    ensure  => present,
    require => Yumrepo[$yum_name],
  }

  #file { "${::artifactory::plugins_dir}/zip_upload.groovy":
  #  source  => 'puppet:///modules/artifactory/zip_upload.groovy',
  #  require => Package[$::artifactory::package_name],
  #  notify  => Service['artifactory'],
  #}
}
