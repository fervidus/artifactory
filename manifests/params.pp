# == Class artifactory::params
#
# This class is meant to be called from artifactory.
# It sets variables according to platform.
#
class artifactory::params {
  
  $is_pro        = false
  $is_ha         = false
  $license_key   = undef
  $plugins_dir   = '/etc/opt/jfrog/artifactory/plugins'
  $cluster_home  = '/mnt/clusterhome'
  $cluster_props = 'cluster.properties'
  $cluster_token = 'sonofabitch'
  $arti_home     = '/var/opt/jfrog/artifactory'
  $jdbc_dir      = '${::artifactory::arti_home}/tomcat/lib'
  $jdbc_file     = '${::artifactory::jdbc_dir}/ojdbc7.jar'
  $hanode_file   = '${::artifactory::arti_home}/etc/ha-node.properties'

  case $::osfamily {
    'Debian': {
      $package_name = 'artifactory'
      $service_name = 'artifactory'
    }
    'RedHat', 'Amazon': {
      $package_name = 'artifactory'
      $service_name = 'artifactory'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

}
