class zabbix::agent inherits zabbix {

  package { 'zabbix-agent':
    ensure => installed,
  }

  service { zabbix-agent:
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package['zabbix-agent']
  }

}
