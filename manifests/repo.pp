# @summary Pull in the platform specific repo classes
# @api private
class artifactory::repo () {
  assert_private()

  if $::artifactory::manage_repo {
    case $facts['os']['family'] {
      'RedHat', 'Linux': {
        contain artifactory::repo::yum
      }

      'Debian': {
        contain artifactory::repo::debian
      }

      default: {
        fail( "Unsupported OS family: ${facts['os']['family']}" )
      }
    }
  }
}
