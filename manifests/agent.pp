class zabbix::agent (
  $version_modifier = ''
) inherits zabbix {

  package { "zabbix${version_modifier}-agent":
    ensure => installed,
  }

  service { 'zabbix-agent':
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package['zabbix-agent']
  }

}
