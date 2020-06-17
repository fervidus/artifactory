# @summary Sets up the debian repository to install artifactory.
#
class artifactory::apt {
  if $::artifactory::manage_repo {
    case $artifactory::edition {
      'pro' : {
        $_url = $artifactory::debian_baseurl_pro
      }
      default : {
        $_url = $artifactory::debian_baseurl
      }
    }

    include apt
    # key is from https://bintray.com/user/downloadSubjectPublicKey?username=jfrog
    apt::source { $::artifactory::debian_name:
      location => $_url,
      key      => 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
      release  => $::lsbdistcodename,
      repos    => 'main'
    }
  }
}
