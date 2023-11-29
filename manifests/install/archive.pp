# @summary Install artifactory from archive
# @api private
class artifactory::install::archive {
  # Add version and edition to filename.
  $filename = sprintf($artifactory::download_filename, $artifactory::edition, $artifactory::package_version)

  # Select download URL.
  case $artifactory::edition {
    'oss' : {
      $url = $artifactory::download_url_oss
    }
    'pro' : {
      $url = $artifactory::download_url_pro
    }
    default : {
      fail("install method ${install_method} does not support edition ${artifactory::edition}")
    }
  }

  # Add version and filename to the download URL.
  $source_url = sprintf($url, $artifactory::package_version, $filename)

  # Setup paths and files.
  $archive_file = "${artifactory::archive_install_dir}/${filename}"
  $install_dir = "${artifactory::archive_install_dir}/artifactory-${artifactory::edition}-${artifactory::package_version}"
  $symlink_full = "${artifactory::archive_install_dir}/${artifactory::symlink_name}"

  # Download and extract the archive.
  archive { $archive_file:
    ensure        => present,
    user          => 'root',
    group         => 'root',
    source        => $source_url,
    extract_path  => $artifactory::archive_install_dir,
    # Extract files as the user doing the extracting, which is the user
    # that runs Puppet, usually root
    extract_flags => '-x --no-same-owner -f',
    creates       => $install_dir,
    extract       => true,
    cleanup       => true,
  }

  # Service should use the symlink, not to real directory, otherwise the
  # wrong version may be used.
  exec { 'fix paths in systemd service':
    path        => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
    command     => "sed -i 's@/opt/jfrog/artifactory@${symlink_full}@' ${install_dir}/app/misc/service/artifactory.service",
    refreshonly => true,
    subscribe   => [
      Archive[$archive_file],
    ],
    require => [
      Archive[$archive_file],
    ],
  }

  # Create the data directory if it does not exist yet.
  # Note that proper permissions cannot be set, because the install
  # script handles user/group creation. Hence this directory must
  # not be altered anymore after initial creation.
  $command = join([
    # Create the data directory.
    "mkdir -p ${artifactory::data_directory}",
    # "Initialize" data directory once by copying files from new installation.
    "&& mv ${install_dir}/var/* ${artifactory::data_directory}/",
  ], ' ')
  exec { 'create data directory':
    path    => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
    # Run this exec only if it does not already exist.
    unless  => "test -d \'${artifactory::data_directory}\'",
    command => $command,
    require => [
      Archive[$archive_file],
    ],
  }

  # Ensure that a symlink for the data directory is created.
  # This ensures that existing data is preserved across updates.
  file { "${install_dir}/var":
    ensure  => link,
    force   => true,
    require => [
      Archive[$archive_file],
      Exec['create data directory'],
    ],
    target  => $artifactory::data_directory,
  }

  # Run installer to setup the Artifactory user, group and service.
  exec { 'setup artifactory service' :
    path        => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
    cwd         => $install_dir,
    command     => "${install_dir}/${artifactory::install_service_script} ${artifactory::config_owner} ${artifactory::config_group}",
    refreshonly => true,
    subscribe   => [
      Archive[$archive_file],
    ],
    require     => [
      Archive[$archive_file],
      Exec['create data directory'],
      Exec['fix paths in systemd service'],
    ],
    notify      => [
      Class[artifactory::config],
      Class[artifactory::service],
    ],
  }

  # Fix permissions, because in previous steps it was not possible to
  # use the correct user/group information.
  exec { 'fix permissions of artifactory data directory' :
    path        => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
    command     => "chown -R ${artifactory::config_owner}:${artifactory::config_group} ${artifactory::data_directory}",
    refreshonly => true,
    subscribe   => [
      Exec['setup artifactory service'],
    ],
  }

  # Set symlink to current version.
  file { $symlink_full:
    ensure  => link,
    require => [
      Archive[$archive_file],
      Exec['setup artifactory service'],
    ],
    target  => $install_dir,
  }
}
