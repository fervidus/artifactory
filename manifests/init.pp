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
  String $yum_name                                                        = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl                                                     = 'https://jfrog.bintray.com/artifactory-rpms',
  String $package_name                                                    = 'jfrog-artifactory',
  Optional[Enum['mssql', 'mysql', 'oracle', 'postgresql']] $db_type       = undef,
  Optional[Integer] $db_port                                              = undef,
  Optional[String] $db_hostname                                           = undef,
  Optional[String] $db_username                                           = undef,
  Optional[String] $db_password                                           = undef,
  Optional[Enum['filesystem', 'fullDb','cachedFS']] $binary_provider_type = undef,
  Optional[Integer] $pool_max_active                                      = undef,
  Optional[Integer] $pool_max_idle                                        = undef,
  Optional[Integer] $binary_provider_cache_maxSize                        = undef,
  Optional[String] $binary_provider_filesystem_dir                        = undef,
  Optional[String] $binary_provider_cache_dir                             = undef,
) {
  $artifactory_home = '/var/opt/jfrog/artifactory'

  $package_name     = 'artifactory'
  $service_name     = 'artifactory'

  class{'::artifactory::yum': }     ->
  class{'::artifactory::install': } ->
  class{'::artifactory::config': }  ~>
  class{'::artifactory::service': }
}
