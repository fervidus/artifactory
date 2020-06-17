# @summary Sets up an apache proxy.
#
class artifactory::apache {

  $servername    = $artifactory::servername
  $serveraliases = ["*.${servername}"]
  $serveradmin   = $artifactory::serveradmin
  $rewrites      = [
    {
      rewrite_cond => '%{SERVER_PORT} (.*)',
      rewrite_rule => '(.*) - [E=my_server_port:%1]'
    },
    {
      comment      => 'NOTE: The REQUEST_SCHEME Header is supported only from apache version 2.4 and above',
      rewrite_cond => '%{REQUEST_SCHEME} (.*)',
      rewrite_rule => '(.*) - [E=my_scheme:%1]'
    },
    {
      rewrite_cond => '%{HTTP_HOST} (.*)',
      rewrite_rule => '(.*) - [E=my_custom_host:%1]'
    },
    {
      rewrite_rule => '^(/)?$      /ui/ [R,L]'
    }
  ]
  $proxy_pass = [
    {
      path            => '/artifactory/',
      url             => 'http://localhost:8081/artifactory/',
      reverse_cookies => [{path => '/', url => '/'}]
    },
    {
      path            => '/',
      url             => 'http://localhost:8082/',
      reverse_cookies => [{path => '/', url => '/'}]
    }
  ]
  $request_headers = [
    'set Host %{my_custom_host}e',
    'set X-Forwarded-Port %{my_server_port}e',
    'set X-Forwarded-Proto %{my_scheme}e',
    "set X-JFrog-Override-Base-Url %{my_scheme}e://${artifactory::servername}:%{my_server_port}e"
  ]

  class{'apache':
    default_vhost => false,
    servername    => $servername,
    mpm_module    => 'event',
  }
  contain apache
  contain apache::mod::rewrite
  contain apache::mod::ssl
  contain apache::mod::proxy
  contain apache::mod::proxy_http

  if $artifactory::use_ssl {
    apache::vhost { 'artifactory-nossl':
      servername => $servername,
      port       => 80,
      docroot    => false,
      rewrites   => [
        {
          comment      => 'redirect to https',
          rewrite_cond => ['%{REQUEST_URI} !=/server-status','%{HTTPS} off'],
          rewrite_rule => ['(.*) https://%{HTTP_HOST}:443%{REQUEST_URI}'],
        },
      ],
    }
    apache::vhost{'artifactory-ssl':
      servername            => $servername,
      serveraliases         => $serveraliases,
      serveradmin           => $serveradmin,
      port                  => 443,
      docroot               => false,
      allow_encoded_slashes => 'on',
      proxy_requests        => false,
      proxy_preserve_host   => true,
      rewrites              => $rewrites,
      proxy_pass            => $proxy_pass,
      request_headers       => $request_headers,
      ssl                   => true,
      ssl_cert              => $artifactory::ssl_cert,
      ssl_key               => $artifactory::ssl_key,
      ssl_chain             => $artifactory::ssl_chain,
      ssl_proxyengine       => true,
    }
  }else{
    apache::vhost{'artifactory':
      servername            => $servername,
      serveraliases         => $serveraliases,
      serveradmin           => $serveradmin,
      port                  => 80,
      docroot               => false,
      allow_encoded_slashes => 'on',
      proxy_requests        => false,
      proxy_preserve_host   => true,
      rewrites              => $rewrites,
      proxy_pass            => $proxy_pass,
      request_headers       => $request_headers,
    }
  }
}
