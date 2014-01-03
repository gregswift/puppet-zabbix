Puppet::Type.newtype(:zabbix_hostgroup) do
  desc "Puppet type that models a Host Group object in Zabbix"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Host group name - should have no spaces"
    munge do |value|
      value.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

end
