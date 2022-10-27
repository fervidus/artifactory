# @summary artifactory:  See README.md for documentation.
#
# @param edition
#   The edition to install from open source to professional.
#
# @param manage_repo
#   True if the apt repo should be managed and false otherwise.
#
# @param use_temp_db_secrets
#   Use a temp db.
#
# @param yum_name
#   The name of the rpm for yum.
#
# @param yum_baseurl
#   The url for the yum repository.
#
# @param yum_baseurl_pro
#   The url for the yum pro repsitory.
#
# @param debian_name
#   The name of the debian folder.
#
# @param debian_baseurl
#   The base url for debian downloads.
#
# @param debian_baseurl_pro
#   The base url for the pro debian downloads.
#
# @param package_name
#   The name of the package for open source.
#
# @param package_name_pro
#  The name of the package for the pro version.
#
# @param package_version
#   The version of the package.
#
# @param artifactory_home
#   The home directory for artifactory.
#
# @param config_owner
#   The owner of the configuration.
#
# @param config_group
#   The group woner of the configuration.
#
#
# @param root_password
#   The root password for artifactory.
#
# @param jdbc_driver_url
#   The url to download jdbc driver.
#
# @param db_type
#   The database type.
#
# @param db_url
#   The url to the database.
#
# @param db_username
#   The database username.
#
# @param db_password
#   The database password.
#
# @param db_automate
#  True if to automate the db and false otherwise.
#
# @param binary_provider_type
#   The type of binary to use.
#
# @param pool_max_active
#   The max pool size.
#
# @param pool_max_idle
#   The max idel pool size.
#
# @param binary_provider_cache_maxsize
#   The binary provider's max cache size.
#
# @param binary_provider_base_data_dir
#   The binary provider's base data directory.
#
# @param binary_provider_filesystem_dir
#   The binary provider's filesystem dir.
#
# @param binary_provider_cache_dir
#   The binary provider's cache dir.
#
# @param master_key
#   The master key.
#
# @param license_key
#   The license key.
#
# @param install_apache
#   Installs an apache server and configures a vhost to proxy to artifactory.
#
# @param servername
#   Sets the Apache server name via Apache's ServerName directive
#
# @param serveradmin
#   Specifies the email address Apache displays when it renders 1 of its error pages.
#
# @param use_ssl
#   If true, configures apache to use SSL.  Port 80 is rewrittent o 443.
#
# @param ssl_cert
#   The public certificate.
#
# @param ssl_key
#   The private ssl certificate.
#
# @param ssl_chain
#   The SSL certificate authority.
#
# @param artifactory_system_properties
#   The system properties for artifactory.
#
class artifactory (
  Enum['oss', 'pro', 'enterprise']
  $edition                                                = 'oss',
  Boolean                 $manage_repo                    = true,
  Boolean                 $use_temp_db_secrets            = true,
  String                  $yum_name                       = 'bintray-jfrog-artifactory-rpms',
  String                  $yum_baseurl                    = 'https://jfrog.bintray.com/artifactory-rpms',
  String                  $yum_baseurl_pro                = 'https://jfrog.bintray.com/artifactory-pro-rpms',
  String                  $debian_name                    = 'bintray-jfrog-artifactory-debs',
  String                  $debian_baseurl                 = 'https://jfrog.bintray.com/artifactory-debs',
  String                  $debian_baseurl_pro             = 'https://jfrog.bintray.com/artifactory-pro-debs',
  String                  $package_name                   = 'jfrog-artifactory-oss',
  String                  $package_name_pro               = 'jfrog-artifactory-pro',
  String                  $package_version                = 'present',
  String                  $artifactory_home               = '/var/opt/jfrog/artifactory',
  String                  $config_owner                   = 'artifactory',
  String                  $config_group                   = 'artifactory',
  String                  $root_password                  = 'password',
  Optional[String]        $jdbc_driver_url                = undef,
  Optional[Enum[
      'derby',
      'mariadb',
      'mssql',
      'mysql',
      'oracle',
      'postgresql',
  ]]                      $db_type                        = undef,
  Optional[String]        $db_url                         = undef,
  Optional[String]        $db_username                    = undef,
  Optional[String]        $db_password                    = undef,
  Boolean                 $db_automate                    = false,
  Optional[Enum[
      'filesystem',
      'fullDb',
      'cachedFS',
      'fullDbDirect',
  ]]                      $binary_provider_type           = undef,
  Optional[Integer]       $pool_max_active                = undef,
  Optional[Integer]       $pool_max_idle                  = undef,
  Optional[Integer]       $binary_provider_cache_maxsize  = undef,
  Optional[String]        $binary_provider_base_data_dir  = undef,
  Optional[String]        $binary_provider_filesystem_dir = undef,
  Optional[String]        $binary_provider_cache_dir      = undef,
  Optional[String]        $master_key                     = undef,
  Optional[String]        $license_key                    = undef,
  Boolean                 $install_apache                 = false,
  Optional[String]        $servername                     = undef,
  Optional[String]        $serveradmin                    = undef,
  Boolean                 $use_ssl                        = false,
  Optional[String]        $ssl_cert                       = undef,
  Optional[String]        $ssl_key                        = undef,
  Optional[String]        $ssl_chain                      = undef,
  Optional[Array[String]] $artifactory_system_properties  = undef,
) {
  $service_name = 'artifactory'

  # check for OS Type
  case $facts['os']['family'] {
    'redhat' : {
      contain artifactory::yum
      Class['artifactory::yum'] -> Class['artifactory::install']

      # version 7 for RPM based install changes the path for configuration files.
      $check_legacy = true
    }
    'debian' : {
      user { 'artifactory':
        home       => $artifactory_home,
        managehome => false,
      }
      include artifactory::apt
      User['artifactory']       -> Class['artifactory::apt']
      Class['artifactory::apt'] -> Class['artifactory::install']

      # debian versions retain the same pathing for configuration files for all versions.
      #$check_legacy = false

      $check_legacy = true
    }
    default  : {
      fail("Unsupported OS ${facts['os']['family']}.  Please use a debian or redhat based system")
    }
  }

  contain artifactory::install
  contain artifactory::config
  contain artifactory::service

  if $install_apache {
    contain artifactory::apache
    Class['artifactory::service'] -> Class['artifactory::apache']
  }

  Class['artifactory::install'] -> Class['artifactory::config'] -> Class['artifactory::service']
}
