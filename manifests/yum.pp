# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::yum {
  # Add the jfrog yum repo
  yumrepo { $::artifactory::yum_name:
    baseurl  => $::artifacotry::yum_baseurl,
    descr    => $::artifactory::yum_name,
    gpgcheck => 0,
    enabled  => 1,
  }
}
