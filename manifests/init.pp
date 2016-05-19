# Class: artifactory
# ===========================
#
# Full description of class artifactory here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#

class artifactory(

  Boolean $is_pro          = $::artifactory::params::is_pro,
  Boolean $is_ha           = $::artifactory::params::is_ha,
  Optional[String] $license_key      = $::artifactory::params::license_key,
  String $package_name     = $::artifactory::params::package_name,
  String $service_name     = $::artifactory::params::service_name,
  String $plugins_dir      = $::artifactory::params::plugins_dir,
  String $cluster_props    = $::artifactory::params::cluster_props,
  String $cluster_token    = $::artifactory::params::cluster_token,
  #String $arti_home        = $::artifactory::params::arti_home,
  #String $jdbc_dir         = $::artifactory::params::jdbc_dir,
  String $jdbc_file        = $::artifactory::params::jdbc_file,
  Optional[String] $clusterhome      = $::artifactory::params::clusterhome,
  Optional[String] $artifactory_nic  = $::artifactory::params::artifactory_nic,
  Boolean $is_primary      = $::artifactory::params::is_primary,
  Integer $membership_port = $::artifactory::params::membership_port,
  String $hanode_file      = $::artifactory::params::hanode_file,
  Optional[String] $db_url           = $::artifactory::params::db_url,
  Optional[String] $db_user          = $::artifactory::params::db_user,
  Optional[String] $db_passwd        = $::artifactory::params::db_passwd,
) inherits ::artifactory::params {

  # If Pro or HA, a license key is needed
  if ($is_ha or $is_pro) and !$license_key {
    fail('Artifactory Pro or HA requires a license key')
  }

  class { '::artifactory::install': } ->
  class { '::artifactory::config': } ~>
  class { '::artifactory::service': } ->
  Class['::artifactory']

}
