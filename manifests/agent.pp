# = Class: zabbix::agent
#
# Configure a Zabbix agent
#
#
# == IMPORTANT
#
# Currently you have to manually setup your database and import the schemas.
#
# == Parameters
#
# [*ensure*]
# String. Controls if the managed resources shall be <tt>present</tt> or
# <tt>absent</tt>. If set to <tt>absent</tt>:
# * The managed software packages are being uninstalled.
# * Any traces of the packages will be purged as good as possible. This may
# include existing configuration files. The exact behavior is provider
# dependent. Q.v.:
# * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
# * {Puppet's package provider source code}[http://j.mp/wtVCaL]
# * System modifications (if any) will be reverted as good as possible
# (e.g. removal of created users, services, changed log settings, ...).
# * This is thus destructive and should be used with care.
# Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
# Boolean.  Whether or not to make sure that packages are always at latest version.
#
# [*version_modifier*]
# String. For RHEL-based distros, versions of zabbix include a periodless modifier to the name.
#
# [*servers*]
# Array. List of servers to configure in zabbix agent.
#
# [*endpoint*]
# String. API endpoint for zabbix web UI for enabling $users
#
#
# == Examples
#
# * Configure zabbix agent to user server zabbix.example.com
# _Note that several of these parameters are defaults._
#
#   class { 'zabbix::agent':
#       servers => ['zabbix.example.com'],
#   }
#
#
class zabbix::agent (
  $ensure           = present,
  $autoupgrade      = false,
  $version_modifier = '20',
  $zabbix_endpoint  = '',
  $servers          = [],
  $endpoint         = '',
) inherits zabbix {

  if $zabbix_endpoint != '' {
    $servers_real = [$zabbix_endpoint]
  } else {
    $servers_real = $servers
  }

  package { "zabbix-agent":
    name   => "zabbix${version_modifier}-agent",
    ensure => installed,
  }

  service { 'zabbix-agent':
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['zabbix-agent']
  }

  file { "/etc/zabbix_agentd.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['zabbix-agent'],
    content => template('zabbix/zabbix_agentd.conf.erb'),
    notify  => Service['zabbix-agent']
  }

  zabbix_host($fqdn, $endpoint)

}
