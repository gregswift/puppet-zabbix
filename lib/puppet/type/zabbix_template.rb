Puppet::Type.newtype(:zabbix_template) do
  desc "Puppet type that models a template object in Zabbix"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Template name - should have no spaces"
    munge do |value|
      value.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:visible_name) do
    desc "Visible template name - currently must be 'friendly' name (e.g. Ethernet)"
  end

  newproperty(:groups, :array_matching => :all) do
    desc "The groups that this template will be in"
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:templates, :array_matching => :all) do
    desc "Templates that this template should link in"
    def insync?(is)
      is.sort == should.sort
    end
  end

end
