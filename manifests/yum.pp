# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::yum {
  if $::artifactory::manage_repo {
    # Add the jfrog yum repo
    yumrepo { $::artifactory::yum_name:
      baseurl  => $::artifactory::yum_baseurl,
      descr    => $::artifactory::yum_name,
      gpgcheck => 0,
      enabled  => 1,
    }
  }
}
