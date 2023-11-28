# @summary Install artifactory from package
# @api private
class artifactory::install::package {
  case $artifactory::edition {
    'enterprise', 'pro' : {
      $_package = $artifactory::package_name_pro
    }
    default : {
      $_package = $artifactory::package_name
    }
  }

  package { $_package:
    ensure  => $::artifactory::package_version,
  }
}
