# == Class artifactory::repo::debian
#
# @summary Set up the apt repo on Debian-based distros
# @api private
class artifactory::repo::debian (
  String $gpg_key_id = 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
) {
  assert_private()

  include apt

  case $artifactory::edition {
    'enterprise', 'pro' : {
      $_url = $artifactory::deb_baseurl_pro
    }
    default : {
      $_url = $artifactory::deb_baseurl
    }
  }

  apt::source { 'artifactory':
    location => $_url,
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    include  => {
      'src' => false,
    },
    key      => {
      'id'     => $gpg_key_id,
      'source' => $artifactory::deb_baseurl_key,
    },
  }
}
