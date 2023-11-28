# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::install {
  case $artifactory::install_method {
    'package': {
      contain artifactory::install::package
      Class['artifactory::install::package']
    }
    'archive': {
      contain artifactory::install::archive
      Class['artifactory::install::archive']
    }
  }
}
