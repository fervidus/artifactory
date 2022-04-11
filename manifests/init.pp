# Class: artifactory:  See README.md for documentation.
# ===========================
#
#
class artifactory(
  Enum['oss', 'pro', 'enterprise'] $edition                                                = 'oss',
  Boolean $manage_repo                                                                     = true,
  Boolean $use_temp_db_secrets                                                             = true,
  String $yum_name                                                                         = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl                                                                      = 'https://jfrog.bintray.com/artifactory-rpms',
  String $yum_baseurl_pro                                                                  = 'https://jfrog.bintray.com/artifactory-pro-rpms',
  String $deb_baseurl                                                                      = 'https://releases.jfrog.io/artifactory/artifactory-debs',
  String $deb_baseurl_pro                                                                  = 'https://releases.jfrog.io/artifactory/artifactory-pro-debs',
  String $deb_baseurl_key                                                                  = 'https://releases.jfrog.io/artifactory/api/gpg/key/public',
  String $package_name                                                                     = 'jfrog-artifactory-oss',
  String $package_name_pro                                                                 = 'jfrog-artifactory-pro',
  String $package_version                                                                  = 'present',
  String $artifactory_home                                                                 = '/var/opt/jfrog/artifactory',
  Optional[String] $config_owner                                                           = 'artifactory',
  Optional[String] $config_group                                                           = 'artifactory',
  Optional[String] $root_password                                                          = 'password',
  Optional[String] $jdbc_driver_url                                                        = undef,
  Optional[Enum['derby', 'mariadb', 'mssql', 'mysql', 'oracle', 'postgresql']] $db_type    = undef,
  Optional[String] $db_url                                                                 = undef,
  Optional[String] $db_username                                                            = undef,
  Optional[String] $db_password                                                            = undef,
  Optional[Boolean] $db_automate                                                           = false,
  Optional[Enum['filesystem', 'fullDb', 'cachedFS', 'fullDbDirect']] $binary_provider_type = undef,
  Optional[Integer] $pool_max_active                                                       = undef,
  Optional[Integer] $pool_max_idle                                                         = undef,
  Optional[Integer] $binary_provider_cache_maxsize                                         = undef,
  Optional[String] $binary_provider_base_data_dir                                          = undef,
  Optional[String] $binary_provider_filesystem_dir                                         = undef,
  Optional[String] $binary_provider_cache_dir                                              = undef,
  Optional[String] $master_key                                                             = undef,
  Optional[String] $license_key                                                            = undef,
) {

  $service_name = 'artifactory'

  Class{'::artifactory::repo': }
  -> class{'::artifactory::install': }
  -> class{'::artifactory::config': }
  -> class{'::artifactory::service': }
}
