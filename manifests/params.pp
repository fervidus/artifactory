# == Class artifactory::params
#
# This class is meant to be called from artifactory.
# It sets variables according to platform.
#
class artifactory::params {
  
  $is_pro               = false
  $is_ha                = false
  $license_key          = undef
  $plugins_dir          = '/etc/opt/jfrog/artifactory/plugins'
  $clusterhome          = undef
  $artifactory_nic      = undef
  $is_primary           = false
  $membership_port      = 10001
  $cluster_props        = 'cluster.properties'
  $cluster_token        = 'detroit'
  $arti_home           = '/var/opt/jfrog/artifactory'
  #$jdbc_dir            = '$arti_home/tomcat/lib'
  #$jdbc_file           = '$jdbc_dir/ojdbc7.jar'
  $hanode_file         = '$arti_home/etc/ha-node.properties'
  #$jdbc_dir            = '/var/opt/jfrog/artifactory/tomcat/lib'
  $jdbc_file            = '/var/opt/jfrog/artifactory/tomcat/lib/ojdbc7.jar'
  $db_url               = undef
  $db_user              = undef
  $db_passwd            = undef

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
