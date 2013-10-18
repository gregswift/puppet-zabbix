class zabbix::agent (
  $version_modifier = '',
  $zabbix_endpoint = '',
) inherits zabbix {

  package { "zabbix-agent":
    name => "zabbix${version_modifier}-agent",
    ensure => installed,
  }

  service { 'zabbix-agent':
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package['zabbix-agent']
  }
  file { "/etc/zabbix_agentd.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['zabbix-agent'],
    content => template('zabbix/zabbix_agentd.conf.erb'),
    notify  => Service['zabbix-agent']
  }
  zabbix_host($fqdn,$environment)

}
