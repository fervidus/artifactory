require 'spec_helper'

describe 'artifactory' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts.merge('root_home' => '/root') }

        context 'artifactory class without any parameters' do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('artifactory::install').that_comes_before('Class[artifactory::config]') }
          it { is_expected.to contain_class('artifactory::config') }
          it { is_expected.to contain_class('artifactory::service') } # .that_subscribes_to('Class[artifactory::config]') }

          it { is_expected.to contain_service('artifactory') }
          it { is_expected.to contain_package('jfrog-artifactory-oss').with_ensure('present') }

          it { is_expected.to contain_class('artifactory::yum') }
          it { is_expected.to contain_class('artifactory') }
          it {
            is_expected.to contain_yumrepo('bintray-jfrog-artifactory-rpms').with(
              'baseurl'  => 'https://jfrog.bintray.com/artifactory-rpms',
              'descr'    => 'bintray-jfrog-artifactory-rpms',
              'gpgcheck' => '1',
              'enabled'  => '1',
              'gpgkey'   => 'https://jfrog.bintray.com/artifactory-rpms/repodata/repomd.xml.key',
            )
          }
        end

        context 'artifactory class with master_key parameter' do
          let(:params) do
            {
              'master_key' => 'masterkey',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/security/master.key').with(
              'content' => 'masterkey',
              'mode' => '0640',
              'owner' => 'artifactory',
              'group' => 'artifactory',
            )
          }
        end

        context 'artifactory class with jdbc_driver_url parameter' do
          let(:params) do
            {
              # super().merge('artifactory_home' => '/var/opt/jfrog/artifactory')
              'jdbc_driver_url' => 'puppet:///modules/my_module/mysql.jar',
              'db_url' => 'oracle://some_url',
              'db_username' => 'username',
              'db_password' => 'password',
              'db_type' => 'oracle',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/tomcat/lib/mysql.jar').with(
              'source' => 'puppet:///modules/my_module/mysql.jar',
              'mode' => '0775',
              'owner' => 'root',
            )
          }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/.secrets/.temp.db.properties').with(
              'ensure' => 'file',
              'mode' => '0640',
              'owner' => 'artifactory',
              'group' => 'artifactory',
            )
          }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/storage.properties').with(
              'ensure' => 'link',
              'target' => '/var/opt/jfrog/artifactory/etc/.secrets/.temp.db.properties',
            )
          }
        end

        context 'artifactory class with use_temp_db_secrets set to false' do
          let(:params) do
            {
              'use_temp_db_secrets' => false,
              # super().merge('artifactory_home' => '/var/opt/jfrog/artifactory')
              'jdbc_driver_url' => 'puppet:///modules/my_module/mysql.jar',
              'db_url' => 'oracle://some_url',
              'db_username' => 'foouser',
              'db_password' => 'foopw',
              'db_type' => 'oracle',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/tomcat/lib/mysql.jar').with(
              'source' => 'puppet:///modules/my_module/mysql.jar',
              'mode' => '0775',
              'owner' => 'root',
            )
          }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/db.properties').with(
              'ensure' => 'file',
              'mode' => '0640',
              'owner' => 'artifactory',
              'group' => 'artifactory',
            )
          }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/storage.properties').with(
              'ensure' => 'link',
              'target' => '/var/opt/jfrog/artifactory/etc/db.properties',
            )
          }
          it do
            is_expected.to contain_augeas('db.properties').with('changes' => [
                                                                  'set "type" "oracle"',
                                                                  'set "url" "oracle://some_url"',
                                                                  'set "driver" "oracle.jdbc.OracleDriver"',
                                                                  'set "username" "foouser"',
                                                                  'set "binary.provider.type" "file-system"',
                                                                ],
                                                                'require' => ['Class[Artifactory::Install]'],
                                                                'notify'  => 'Class[Artifactory::Service]')
          end
          it do
            is_expected.to contain_augeas('db.properties.pw').with('changes' => [
                                                                     'set "password" "foopw"',
                                                                   ],
                                                                   'onlyif'  => 'match /files/var/opt/jfrog/artifactory/etc/db.properties/password size == 0',
                                                                   'require' => ['Class[Artifactory::Install]'],
                                                                   'notify'  => 'Class[Artifactory::Service]')
          end
        end

        context 'mysql automated database' do
          let(:params) do
            {
              'db_automate' => true,
              'db_type'     => 'mysql',
              'root_password' => 'password',
              'db_username' => 'artifactory',
              'db_password' => 'password',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_class('mysql::server').with(
              'package_name'            => 'mariadb-server',
              'package_ensure'          => '5.5.60-1.el7_5',
              'remove_default_accounts' => true,
              'root_password'           => 'password',
              # 'password' => 'password',
              # 'user' => 'user',
            )
          }
        end

        context 'running a legacy version (pre v7)' do
          let(:params) do
            {
              'package_version' => '6.0.0',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_package('jfrog-artifactory-oss').with(
              'ensure' => '6.0.0',
            )
          }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').with_content(%r{chain template="file-system"})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').without_content(%r{<provider id="file-system" type="file-system">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').without_content(%r{<fileStoreDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').without_content(%r{<baseDataDir>})
          }
        end

        context 'running a current version' do
          let(:params) do
            {
              'package_version' => '7.4.3',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_package('jfrog-artifactory-oss').with(
              'ensure' => '7.4.3',
            )
          }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{chain template="file-system"})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<provider id="file-system" type="file-system">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<fileStoreDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<baseDataDir>})
          }
        end

        context 'running a current version with a custom binary filesystem dir' do
          let(:params) do
            {
              'package_version' => '7.4.3',
              'binary_provider_filesystem_dir' => '/opt/artifactory-filestore',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<provider id="file-system" type="file-system">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<fileStoreDir>/opt/artifactory-filestore</fileStoreDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<baseDataDir>})
          }
        end

        context 'running a current version with a custom binary base data dir' do
          let(:params) do
            {
              'package_version' => '7.4.3',
              'binary_provider_base_data_dir' => '/opt/artifactory-data',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<baseDataDir>/opt/artifactory-data</baseDataDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<fileStoreDir>/opt/artifactory-data/filestore</fileStoreDir>})
          }
        end
      end
    end
  end
end
