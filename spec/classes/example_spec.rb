require 'spec_helper'

describe 'artifactory' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "artifactory class without any parameters" do
          it { is_expected.to compile.with_all_deps }

#          it { is_expected.to contain_class('artifactory::params') }
          it { is_expected.to contain_class('::artifactory::install').that_comes_before('::artifactory::config') }
          it { is_expected.to contain_class('::artifactory::config') }
          it { is_expected.to contain_class('::artifactory::service').that_subscribes_to('::artifactory::config') }

          it { is_expected.to contain_service('artifactory') }
          it { is_expected.to contain_package('jfrog-artifactory-oss').with_ensure('present') }
        end
      end
    end
  end

  #context 'unsupported operating system' do
  #  describe 'artifactory class without any parameters on Solaris/Nexenta' do
  #    let(:facts) do
  #      {
  #        :osfamily        => 'Solaris',
  #        :operatingsystem => 'Nexenta',
  #      }
  #    end

  #    it { expect { is_expected.to contain_package('jfrog-artifactory-oss') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
  #  end
  #end
end
