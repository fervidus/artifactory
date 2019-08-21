# Class: artifactory:  See README.md for documentation.
# ===========================
#
#
class artifactory(
  Boolean $manage_java                                                                     = true,
  Boolean $manage_repo                                                                     = true,
  Boolean $use_temp_db_secrets                                                             = true,
  String $yum_name                                                                         = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl                                                                      = 'http://jfrog.bintray.com/artifactory-rpms',
  String $package_name                                                                     = 'jfrog-artifactory-oss',
  String $package_version                                                                  = 'present',
  String $artifactory_home                                                                 = '/var/opt/jfrog/artifactory',
  Optional[String] $root_password                                                          = 'password',
  Optional[String] $jdbc_driver_url                                                        = undef,
  Optional[Enum['derby', 'mssql', 'mysql', 'oracle', 'postgresql']] $db_type               = undef,
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
) {

  $service_name = 'artifactory'

  if ($manage_java) {
    # Ensure other open-jdk packages are removed
    $remove_jdks = [
      'java-1.6.0-openjdk-devel',
      'java-1.6.0-openjdk',
      'java-1.7.0-openjdk-devel',
      'java-1.7.0-openjdk',
    ]

    package { $remove_jdks:
      ensure => absent,
    }

    class{'::java':
      version => latest,
      package => 'java-1.8.0-openjdk-devel',
    }

    Class['::java']
    -> class{'::artifactory::yum': }
    -> class{'::artifactory::install': }
    -> class{'::artifactory::config': }
    ~> class{'::artifactory::service': }

    # Make sure java is included
    include ::java
  } else {
    Class{'::artifactory::yum': }
    -> class{'::artifactory::install': }
    -> class{'::artifactory::config': }
    ~> class{'::artifactory::service': }
  }
}
