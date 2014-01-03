class zabbix::proxy (
  $database         = undef,
  $version_modifier = '',
) {

    $type = 'proxy'

    $packages = $database ? {
        mysql   => [ "zabbix${version_modifier}-${type}", "zabbix${version_modifier}-${type}-mysql" ],
        pgsql   => [ "zabbix${version_modifier}-${type}", "zabbix${version_modifier}-${type}-pgsql" ],
        sqlite  => [ "zabbix${version_modifier}-${type}", "zabbix${version_modifier}-${type}-sqlite3" ],
        default => [ "zabbix${version_modifier}-${type}" ],
    }

    package { "zabbix-proxy':
        name   => $packages,
        ensure => installed,
    }

    service { "zabbix-proxy':
        enable     => true,
        ensure     => running,
        hasrestart => true,
        hasstatus  => true,
    }

}
