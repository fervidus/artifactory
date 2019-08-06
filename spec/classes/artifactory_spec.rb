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
          it { is_expected.to contain_package('java-1.6.0-openjdk-devel').with_ensure('absent') }
          it { is_expected.to contain_package('java-1.6.0-openjdk').with_ensure('absent') }
          it { is_expected.to contain_package('java-1.7.0-openjdk-devel').with_ensure('absent') }
          it { is_expected.to contain_package('java-1.7.0-openjdk').with_ensure('absent') }
          it {
            is_expected.to contain_yumrepo('bintray-jfrog-artifactory-rpms').with(
              'baseurl'  => 'http://jfrog.bintray.com/artifactory-rpms',
              'descr'    => 'bintray-jfrog-artifactory-rpms',
              'gpgcheck' => '0',
              'enabled'  => '1',
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

        context 'artifactory class with manage_java set to false' do
          let(:params) do
            {
              'manage_java' => false,
            }
          end

          it { is_expected.to compile.with_all_deps }
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

        context 'artifactory class with version specified' do
          let(:params) do
            {
              'package_version' => '5.9.1',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_package('jfrog-artifactory-oss').with(
              'ensure' => '5.9.1',
            )
          }
        end
      end
    end
  end
end
