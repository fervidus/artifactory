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
  Boolean $is_pro      = $::artifactory::params::is_pro,
  String $license_key  = $::artifactory::params::license_key,
  String $package_name = $::artifactory::params::package_name,
  String $service_name = $::artifactory::params::service_name,
  String $plugins_dir  = $::artifactory::params::plugins_dir,
) inherits ::artifactory::params {

  # If pro a license key is needed
  if $is_pro and !$license_key {
    fail('Artifactory pro require a license key')
  }

  class { '::artifactory::install': } ->
  class { '::artifactory::config': } ~>
  class { '::artifactory::service': } ->
  class { '::artifactory::license': } ->
  Class['::artifactory']
}
