# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::install {
  case $artifactory::edition {
    'enterprise', 'pro' : {
      $_package = $artifactory::package_name_pro
    }
    default : {
      $_package = $artifactory::package_name
    }
  }

  package { $_package:
    ensure  => $artifactory::package_version,
  }
}
