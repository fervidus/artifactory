[![Build Status](https://travis-ci.org/fervid/artifactory.svg?branch=master)](https://travis-ci.org/fervid/artifactory)
[![Puppet Forge](https://img.shields.io/puppetforge/v/fervid/artifactory.svg)](https://forge.puppetlabs.com/fervid/artifactory)
[![Puppet Forge](https://img.shields.io/puppetforge/f/fervid/artifactory.svg)](https://forge.puppetlabs.com/fervid/artifactory)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with artifactory](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with artifactory](#beginning-with-artifactory)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This will install Artifactory OSS or PRO.
Artifactory 7+ is supported, legacy support for Artifactory 6 is still available.

If you are looking for the HA installation look at:

Artifactory HA: https://forge.puppet.com/fervid/artifactory_ha

Github and gitlab are great for storing source control, but bad at storing installers and compiled packages.

This is where Artifactory comes in. It stores all of your organizations artifacts in an organized and secure manner.

## Module Description

The Artifactory module installs, configures, and manages the Artifactory open source binary repository.

The Artifactory module manages both the installation and database configuration of Artifactory OSS.

## Setup

### Beginning with artifactory

If you want a server installed with the default options you can run
`include '::artifactory'`.

However, it is strongly recommended to specify the desired version of Artifactory:

```puppet
class { '::artifactory':
  package_version => '7.4.3',
```

This ensures that the module behaves correctly and does not enable obsolete features for your version of Artifactory.

If you need to add database connectivity instantiate with the required parameters:

~~~
class { '::artifactory':
  jdbc_driver_url                => 'puppet:///modules/my_module/mysql.jar',
  db_type                        => 'oracle',
  db_url                         => 'jdbc:oracle:thin:@somedomain.com:1521:arti001',
  db_username                    => 'my_username',
  db_password                    => 'efw23gn2j3',
  binary_provider_type           => 'filesystem',
  pool_max_active                => 100,
  pool_max_idle                  => 10,
  binary_provider_cache_maxsize  => $binary_provider_cache_maxsize,
  binary_provider_filesystem_dir => '/var/opt/jfrog/artifactory/data/filestore',
  binary_provider_cache_dir      => '/var/opt/jfrog/artifactory/',
}
~~~

### Artifactory with PostgreSQL database

This installs PostgreSQL 11 and artifactory. PostgreSQL 12 isn't supported yet
by Artifactory. This code is tested on CentOS 7.

```puppet
class {'postgresql::globals':
  version => '11',
  manage_package_repo => true,
}
include postgresql::server

postgresql::server::db {'artifactory':
  user => 'artifactory',
  password => postgresql_password('artifactory', 'RANDOM_PASSWORD_SHOULD_BE_INSERTED_HERE'),
}
class { 'artifactory':
  db_type => 'postgresql',
  db_username => 'artifactory',
  db_password => '45y43y58y435hitr',
  db_url      => 'jdbc:postgresql:127.0.0.1:5432/artifactory',
  require     => Postgresql::Server::Db['artifactory']
}
```

### Install commercial version

To install a commercial version of Artifactory:

```puppet
class { '::artifactory':
  edition     => 'pro',
  license_key => 'ABCDEFG1234567890',
  ...
}
```

## Usage

All interaction for the server is done via `::artifactory`.

## Reference

### Classes

#### Public classes

* [`artifactory`](#artifactoryserver): Installs and configures Artifactory.

#### Private classes

* `artifactory::yum`: Installs yum configuration.
* `artifactory::install`: Installs packages.
* `artifactory::config`: Configures Artifactory.
* `artifactory::service`: Manages service.
* `artifactory::mysql`: Manages an automated mysql database

### Parameters

#### artifactory

##### `yum_name`

Sets the name of the yum repository. Defaults to 'bintray-jfrog-artifactory-rpms'.

This can be changed if Artifactory needs to be setup from a different repository. Typically this is done if an organization has a 'trusted' yum repo.

##### `yum_baseurl`

Sets the base url of the yum repository to name. Defaults to 'http://jfrog.bintray.com/artifactory-rpms'.

This can be changed if Artifactory needs to be setup from a different repository. Typically this is done if an organization has a 'trusted' yum repo.

##### `package_name`

Sets the package name to install. Defaults to 'jfrog-artifactory-oss'.

This can be changed if Artifactory needs to install a differently named package. Possibly needed if na organization creates their own Artifactory package.

##### `package_version`

Sets the package version to. Defaults to 'present'.

This can be changed if you need to install a specific version. It takes the same values allowed for the `ensure` parameter of the standard `package` resource type.


##### `manage_java`

Tells the module whether or not to manage the java class. This defaults to true. Usually this is what you want.

If your organization actively manages the java installs across your environment set this to false.

##### `root_password`

Sets the root password for Puppet managed mysql database

##### `jdbc_driver_url`

Sets the location for the jdbc driver. The built-in `file` type is used to retrieve the driver.

This is required if using a new data source.

##### `use_temp_db_secrets`

Set to true(default) if you want Artifactory to delete temporary db.properties file on service start.
https://www.jfrog.com/confluence/display/RTF/Configuring+Security#ConfiguringSecurity-HardeningSecurityforSecrets

Set to false if you would like db.properties file to be written to ${::artifactory::artifactory_home}/etc/db.properties
and managed with Augeas, taking into account Artifactory encrypts password field on startup. Management with Augeas
allows user to add additional database and storage options to db.properties without Puppet touching.

##### `db_automate`

Set to 'true' if you want Puppet to create a database. Only works with **mysql**. If `true`, we recommend using JDBC connector version 5.1.24. NOTE: Puppet may throw an error the first run while it waits for Artifactory to connect to database

##### `db_type`

Only required for database configuration. The type of database to configure for. Valid values are 'mariadb', 'mssql', 'mysql', 'oracle', 'postgresql'.

##### `db_url`

Only required for database configuration. The url of the database.

##### `db_username`

Only required for database configuration. The username for the database account.

##### `db_password`

Only required for database configuration. The password for the database account.

##### `binary_provider_type`

Optional setting for the binary storage provider. The type of database to configure for. Valid values are 'filesystem', 'fullDb', 'cachedFS', 'S3'. Defaults to 'filesystem'.

###### filesystem (default)
This means that metadata is stored in the database, but binaries are stored in the file system. The default location is under $ARTIFACTORY_HOME/data/filestore however this can be modified.

###### fullDb
All the metadata and the binaries are stored as BLOBs in the database, objects are cached as in cachedFS.

###### cachedFS
Works the same way as filesystem but also has a binary LRU (Least Recently Used) cache for upload/download requests. Improves performance of instances with high IOPS (I/O Operations) or slow NFS access.

###### S3
This is the setting used for S3 Object Storage.

###### fullDbDirect
All the metadata and the binaries are stored as BLOBs in the database. No caching occurs.

##### `pool_max_active`

Optional setting for the maximum number of pooled database connections. Defaults to 100.

##### `pool_max_idle`

Optional setting for the maximum number of pooled idle database connections Defaults to 10.

##### `binary_provider_cache_maxsize`

Optional setting for the maximum cache size. This value specifies the maximum cache size (in bytes) to allocate on the system for caching BLOBs.

##### `binary_provider_base_data_dir`

Optional setting for the artifactory filestore base location. Defaults to '$ARTIFACTORY_HOME/data'.

##### `binary_provider_filesystem_dir`

Optional setting for the artifactory filestore location. If the binary.provider.type is set to filesystem this value specifies the location of the binaries in combination with binary_provider_base_data_dir. Defaults to 'filestore'.

##### `binary_provider_cache_dir`

Optional setting for the location of the cache. This should be set to your $ARTIFACTORY_HOME directory directly (not on the NFS).

##### `master_key`

Optional setting for the master key that Artifactory uses to connect to the database. If specified, it ensures that if your node terminates, a new one can be spun up that can connect to the same database as before. Otherwise, Artifactory will generate a new master key on first run.

## Limitations

This module has been tested on:

* RedHat Enterprise Linux 5, 6, 7, 8
* CentOS 5, 6, 7, 8

## Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.


### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/fervid/artifactory/graphs/contributors)
