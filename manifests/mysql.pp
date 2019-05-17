# Manages mysql server if automated
class artifactory::mysql {
  class { '::mysql::server':
    package_name            => 'mariadb-server',
    package_ensure          => '5.5.60-1.el7_5',
    root_password           => $::artifactory::root_password,
    remove_default_accounts => true,
  }

  mysql::db { 'artdb':
    user     => $::artifactory::db_username,
    password => $::artifactory::db_password,
    dbname   => 'artdb',
    host     => 'localhost',
    grant    => 'ALL',
  }
}
