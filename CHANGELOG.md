# Changelog

2022-05-24 Release 3.0.6

* Added a new System System Property
* Added Ubuntu Support.
* Updated to latest PDK Version.
* Added Puppet 6 support.

2020-08-26 Release 3.0.1

* Fix for PR 11

2020-16-05 Release 3.0.0

* Thanks to fraenki
* Add support for Artifactory 7

2020-06-04 Release 2.2.8

Several fixes by Tim Meusel.

* Litmus testing added
* Add PostGres example

2019-22-08 Release 2.2.7

Several fixes by Ron Aughenbaugh from University of Maryland. Go Terrapins.

* Manage db.properties with augeas
* Added optional params to db.properties with augeas
* Fix hardcoding of paths

2019-14-08 Release 2.2.5

* Alexander Hermes bumped java dependency
* Frank Wall fixed bug where service restarted on .temp.db.properties change 

2019-20-05 Release 2.1.0

* Database secrets are now read from a temporary file, allowing for encrypted passwords
* Master key for database can now be specified to re-use an existing database
* Module can now provision a Mysql database and connect it to Artifactory
* Smoothed out install script for better compatability with database

2018-22-08 Release 2.0.16

* Refactored for PDK and ensured all test pass.

2018-13-08 Release 2.0.14

* Refactored for PDK and ensured all test pass.

2018-03--14 Release 2.0.13

* Remove OJDBC JAR file and ha-node prop files
* Make artifactory version configurable

2018-02-28 Release 2.0.12

* Added fix for manage_java = false dependency
* Added enhancement for derby usage

2017-03-21 Release 2.0.9

* Fix simple puppet linter problems

2017-03-21 Release 2.0.8

* Change from wget to file type to grab binary drivers

2016-08-14 Release 2.0.7

* Fix JDBC permissions

2016-08-14 Release 2.0.5

* JDBC driver added as owner root, not artifactory

2016-07-26 Release 2.0.0

* Remove db_hostname and db_port. Use db_url instead.

2016-07-22 Release 1.0.5

* Added active management of java to module

2016-07-22 Release 1.0.3

* Added shields and final travis-ci tests
