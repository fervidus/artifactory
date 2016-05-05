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

  Boolean $is_pro        = $::artifactory::params::is_pro,
  Boolean $is_ha         = $::artifactory::params::is_ha,
  String $license_key    = $::artifactory::params::license_key,
  String $package_name   = $::artifactory::params::package_name,
  String $service_name   = $::artifactory::params::service_name,
  String $plugins_dir    = $::artifactory::params::plugins_dir,
  String $cluster_home   = $::artifactory::params::cluster_home,
  String $cluster_props  = $::artifactory::params::cluster_props,
  String $cluster_token  = $::artifactory::params::cluster_token,

) inherits ::artifactory::params {

  # If Pro or HA, a license key is needed
  if ($is_ha or $is_pro) and !$license_key {
    fail('Artifactory Pro or HA requires a license key')
  }

  class { '::artifactory::install': } ->
  class { '::artifactory::config': } ~>
  class { '::artifactory::service': } ->
  class { '::artifactory::license': } ->
  Class['::artifactory']

}
