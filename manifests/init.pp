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
  String $package_name                                                    = $::artifactory::params::package_name,
  String $service_name                                                    = $::artifactory::params::service_name,
  Optional[Enum['mssql', 'mysql', 'oracle', 'postgresql']] $db_type       = $::artifactory::params::db_type,
  Optional[Integer] $db_port                                              = $::artifactory::params::db_port,
  Optional[String] $db_hostname                                           = $::artifactory::params::db_hostname,
  Optional[String] $db_username                                           = $::artifactory::params::db_username,
  Optional[String] $db_password                                           = $::artifactory::params::db_password,
  Optional[Enum['filesystem', 'fullDb','cachedFS']] $binary_provider_type = $::artifactory::params::binary_provider_type,
  Optional[Integer] $pool_max_active                                      = $::artifactory::params::pool_max_active,
  Optional[Integer] $pool_max_idle                                        = $::artifactory::params::pool_max_idle,
  Optional[Integer] $binary_provider_cache_maxSize                        = $::artifactory::params::binary_provider_cache_maxSize,
  Optional[String] $binary_provider_filesystem_dir                        = $::artifactory::params::binary_provider_filesystem_dir,
  Optional[String] $binary_provider_cache_dir                             = $::artifactory::params::binary_provider_cache_dir,
) inherits ::artifactory::params {
  $artifactory_home = '/var/opt/jfrog/artifactory'

  contain ::artifactory::yum
  contain ::artifactory::install
  contain ::artifactory::config
  contain ::artifactory::service

  Class['::artifactory::yum']     ->
  Class['::artifactory::install'] ->
  Class['::artifactory::config']  ~>
  Class['::artifactory::service']
}
