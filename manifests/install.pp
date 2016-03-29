# == Class artifactory::install
#
# This class is called from artifactory for install.
#
class artifactory::install {
  # Add the jfrog yum repo
  yumrepo {'bintraybintray-jfrog-artifactory-rpms':
    baseurl  => 'https://jfrog.bintray.com/artifactory-rpms',
    gpgcheck => 0,
    enabled  => 1,
  }


  package { 'artifactory':
    ensure  => present,
    require => Yumrepo['bintraybintray-jfrog-artifactory-rpms'],
  }
}
