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
  String           $package_name     = $::artifactory::params::package_name,
  String           $service_name     = $::artifactory::params::service_name,
) inherits ::artifactory::params {
  contain ::artifactory::yum
  contain ::artifactory::install
  contain ::artifactory::config
  contain ::artifactory::service

  Class['::artifactory::yum']     ->
  Class['::artifactory::install'] ->
  Class['::artifactory::config']  ~>
  Class['::artifactory::service'] ->
  Class['::artifactory']

}
