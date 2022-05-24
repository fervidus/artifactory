# @summary artifactory:  See README.md for documentation.
#
# @param install_apache
#   Installs an apache server and configures a vhost to proxy to artifactory.
#
# @parm servername
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
class artifactory(
  Enum[
    'oss',
    'pro',
    'enterprise']         $edition                        = 'oss',
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
  Optional[String]        $config_owner                   = 'artifactory',
  Optional[String]        $config_group                   = 'artifactory',
  Optional[String]        $root_password                  = 'password',
  Optional[String]        $jdbc_driver_url                = undef,
  Optional[Enum[
    'derby',
    'mariadb',
    'mssql',
    'mysql',
    'oracle',
    'postgresql']]        $db_type                        = undef,
  Optional[String]        $db_url                         = undef,
  Optional[String]        $db_username                    = undef,
  Optional[String]        $db_password                    = undef,
  Optional[Boolean]       $db_automate                    = false,
  Optional[Enum[
    'filesystem',
    'fullDb',
    'cachedFS',
    'fullDbDirect']]      $binary_provider_type           = undef,
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
  case $facts['os']['family']{
    'redhat' : {
      contain artifactory::yum
      Class['artifactory::yum'] -> Class['artifactory::install']

      # version 7 for RPM based install changes the path for configuration files.
      $check_legacy = true
    }
    'debian' : {
      user{'artifactory':
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
