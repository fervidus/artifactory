# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::yum {
  if $::artifactory::manage_repo {
    case $artifactory::edition {
      'pro' : {
        $_url = $artifactory::yum_baseurl_pro
      }
      default : {
        $_url = $artifactory::yum_baseurl
      }
    }

    # Add the jfrog yum repo
    yumrepo { $::artifactory::yum_name:
      baseurl  => $_url,
      descr    => $::artifactory::yum_name,
      gpgcheck => 0,
      enabled  => 1,
    }
  }
}
