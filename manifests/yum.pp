# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::yum {
  $yum_name = 'bintray-jfrog-artifactory-rpms'
  $yum_baseurl = 'https://jfrog.bintray.com/artifactory-rpms'

  # Add the jfrog yum repo
  yumrepo { $yum_name:
    baseurl  => $yum_baseurl,
    descr    => $yum_name,
    gpgcheck => 0,
    enabled  => 1,
  }
}
