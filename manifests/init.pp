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
  String $license_key = $::artifactory::params::license_key,
  String $package_name = $::artifactory::params::package_name,
  String $service_name = $::artifactory::params::service_name,
) {

  # validate parameters here

  class { '::artifactory::install': } ->
  class { '::artifactory::config': } ~>
  class { '::artifactory::service': } ->
  Class['::artifactory']
}
