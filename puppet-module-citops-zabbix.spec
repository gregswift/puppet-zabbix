%define base_name zabbix

Name:      puppet-module-citops-%{base_name}
Version:   0.1.1
Release:   1
BuildArch: noarch
Summary:   Puppet module to configure %{base_name}
License:   GPLv3+
URL:       http://github.rackspace.com/cloud-integration-ops/puppet-%{base_name}
Source0:   %{name}.tgz

%description
Puppet module for fairly extensi
%define module_dir /usr/share/puppet/modules/%{base_name}

%prep
%setup -q -c -n %{base_name}

%build

%install
mkdir -p %{buildroot}%{module_dir}
cp -pr * %{buildroot}%{module_dir}/

%files
%defattr (0644,root,root)
%{module_dir}

%changelog
* Thu Aug  28 Tony Rogers <tony.rogers@rackspace.com> - 0.1.1-1
- Bump Version

* Wed Aug  27 Tony Rogers <tony.rogers@rackspace.com> - 0.1.0-1
- Bumping version to match release

* Fri Jan  3 Greg Swift <greg.swiftr@rackspace.com> - 0.0.1-1
- Initial version of the package
