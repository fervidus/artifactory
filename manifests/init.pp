# Class: artifactory:  See README.md for documentation.
# ===========================
#
# @param archive_data_dir
#   The Artifactory data directory that should be used for archive installations.
#
# @param archive_install_dir
#   The Artifactory app directory that should be used for archive installations.
#
# @param download_filename
#   The filename of the archive distribution.
#
# @param download_url_oss
#   The download URL for the open-source edition.
#
# @param download_url_oss
#   The download URL for the pro edition.
#
# @param install_method
#   Whether to use a package or an archive to install artifactory.
#
# @param install_service_script
#   Path to the installation script of the archive distribution.
#
# @param symlink_name
#   Controls the name of a version-independent symlink for the archive
#   installation. It will always point to the release specified by `$package_version`.
#
class artifactory(
  Enum['oss', 'pro', 'enterprise'] $edition                                                = 'oss',
  Boolean $manage_repo                                                                     = true,
  Boolean $use_temp_db_secrets                                                             = true,
  String $yum_name                                                                         = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl                                                                      = 'https://jfrog.bintray.com/artifactory-rpms',
  String $yum_baseurl_pro                                                                  = 'https://jfrog.bintray.com/artifactory-pro-rpms',
  String $package_name                                                                     = 'jfrog-artifactory-oss',
  String $package_name_pro                                                                 = 'jfrog-artifactory-pro',
  String $package_version                                                                  = 'present',
  String $artifactory_home                                                                 = '/var/opt/jfrog/artifactory',
  String $install_method                                                                   = 'package',
  String $download_filename                                                                = 'jfrog-artifactory-%s-%s-linux.tar.gz',
  String $download_url_oss                                                                 = 'https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/%s/%s',
  String $download_url_pro                                                                 = 'https://releases.jfrog.io/artifactory/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/%s/%s',
  String $symlink_name                                                                     = 'artifactory',
  String $install_service_script                                                           = 'app/bin/installService.sh',
  Stdlib::Absolutepath $archive_install_dir                                                = '/opt',
  Stdlib::Absolutepath $archive_data_dir                                                   = '/opt/artifactory-data',
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

  # Artifactory's data directory depends on the installation method.
  if ($install_method == 'package') {
    $data_directory = $artifactory_home
  } else {
    $data_directory = $archive_data_dir
  }

  Class{'::artifactory::yum': }
  -> class{'::artifactory::install': }
  -> class{'::artifactory::config': }
  -> class{'::artifactory::service': }
}
