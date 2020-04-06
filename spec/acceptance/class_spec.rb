require 'spec_helper_acceptance'

describe 'artifactory class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-ARTIFACTORY_TEST
      class { 'artifactory': }
      ARTIFACTORY_TEST

      # Run it twice and test for idempotency
      idempotent_apply(pp)
    end

    describe package('jfrog-artifactory-oss') do
      it { is_expected.to be_installed }
    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8081) do
      it { is_expected.to be_listening }
    end
  end

  context 'with postgresql' do # , if: fact('os.release.major') == '7' do
    it 'works idempotently with no errors' do
      pp = <<-PUPPETCODE
      class {'postgresql::globals':
        version => '11',
        manage_package_repo => true,
      }
      include postgresql::server

      postgresql::server::db {'artifactory':
        user => 'artifactory',
        password => postgresql_password('artifactory', '45y43y58y435hitr'),
      }
      class { 'artifactory':
        db_type => 'postgresql',
        db_username => 'artifactory',
        db_password => '45y43y58y435hitr',
        db_url      => 'jdbc:postgresql:127.0.0.1:5432/artifactory',
        require     => Postgresql::Server::Db['artifactory']
      }
      PUPPETCODE

      # Run it twice and test for idempotency
      idempotent_apply(pp)
    end

    describe package('jfrog-artifactory-oss') do
      it { is_expected.to be_installed }
    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8081) do
      it { is_expected.to be_listening }
    end
  end
end
