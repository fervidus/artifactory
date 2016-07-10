# Class: artifactory:  See README.md for documentation.
# ===========================
#
#
class artifactory(
  String $yum_name                                                        = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl                                                     = 'http://jfrog.bintray.com/artifactory-rpms',
  String $package_name                                                    = 'jfrog-artifactory-oss',
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

  $service_name = 'artifactory'

  class{'::artifactory::yum': }     ->
  class{'::artifactory::install': } ->
  class{'::artifactory::config': }  ~>
  class{'::artifactory::service': }
}
