# == Class artifactory::repo::yum
#
class artifactory::repo::yum {
  if $::artifactory::manage_repo {
    case $artifactory::edition {
      'enterprise', 'pro' : {
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
      gpgcheck => 1,
      enabled  => 1,
      gpgkey   => "${_url}/repodata/repomd.xml.key",
    }
  }
}
