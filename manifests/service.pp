# == Class artifactory::service
#
# This class is meant to be called from artifactory.
# It ensure the service is running.
#
class artifactory::service {

  service { $::artifactory::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
