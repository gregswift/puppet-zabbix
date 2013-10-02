class zabbix::server (
  $database = undef,
  $version_modifier = '',
) inherits zabbix {

    case $database {
        'mysql': {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}", "zabbix${version_modifier}-mysql"]
        }
        'pgsql': {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}", "zabbix${version_modifier}-pgsql"]
        }
        'sqlite': {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}", "zabbix${version_modifier}-sqlite3"]
        }
        default: {
            $zbxsvr_pkg_names = ["zabbix${version_modifier}"]
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
