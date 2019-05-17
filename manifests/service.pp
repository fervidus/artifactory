# == Class artifactory::service
#
# This class is meant to be called from artifactory.
# It ensure the service is running.
#
class artifactory::service {
  service { 'artifactory':
    ensure => running,
    enable => true,
  }
}
