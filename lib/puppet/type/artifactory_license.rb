require 'uri'

Puppet::Type.newtype(:artifactory_license) do
  @doc = "Installs a license onto Artifactory."
  ensurable

  autorequire(:package) do
    'rest-client'
  end

  newparam(:artifactory_url, :namevar => true) do
    desc "The url where Artifactory can be found."

    validate do |value|
      raise ArgumentError, "The artifactory location. Looking for the protocol, hostname and possibly port. Example: http://artifactory.mydomain.com/artifactory." if value.empty?

      unless value =~ URI.regexp
        raise ArgumentError, "The Artifactory url is not a properly formatted url"
      end
    end
  end

  newparam(:source_url) do
    desc "The url of the file to sync."

    validate do |value|
      raise ArgumentError, "The source url must not be empty." if value.empty?

      unless value =~ URI.regexp
        raise ArgumentError, "The source url is not a properly formatted url"
      end
    end
  end

  newproperty(:license) do
    desc "The license to be installed"

    validate do |value|
      raise ArgumentError, "The license must not be empty." if value.empty?
    end
  end

  newparam(:user) do
    desc "The user for Artifactory basic auth."

    validate do |value|
      raise ArgumentError, "A user with admin privledges must be included." if value.empty?
    end
  end

  newparam(:password) do
    desc "The user password for Artifactory basic auth."

    validate do |value|
      raise ArgumentError, "A password for an admin user must be included." if value.empty?
    end
  end

  newparam(:ignore_unauthorized) do
    defaultto :true
    newvalues(:true, :false)
  end
end
