class zabbix::server (
  $database = undef,
  $version_modifier = '',
) inherits zabbix {
    $type = 'server'
    case $database {
        'mysql': {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}-${type}", "zabbix${version_modifier}-${type}-mysql"]
        }
        'pgsql': {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}-${type}", "zabbix${version_modifier}-${type}-pgsql"]
        }
        'sqlite': {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}-${type}", "zabbix${version_modifier}-${type}-sqlite3"]
        }
        default: {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}-${type}"]
        }
    }

    package { "zabbix-server':
        name => $zbxsvr_pkg_names,
        ensure => installed,
    }

    service { "zabbix-server':
        enable => true,
        ensure => running,
        hasrestart => true,
        hasstatus => true,
    }

}
