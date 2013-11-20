class zabbix::agent (
  $version_modifier = '20',
  $zabbix_endpoint = '',
  $servers = []
) inherits zabbix {
  if $zabbix_endpoint != '' {
    $servers_real = [$zabbix_endpoint]
  } else {
    $servers_real = $servers
  }
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
