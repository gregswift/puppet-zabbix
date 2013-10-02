class zabbix::server ($database=undef) inherits zabbix {

    case $database {
        'mysql': {
            $zbxsvr_pkg_names = ['zabbix-server', 'zabbix-server-mysql']
        }
        'pgsql': {
            $zbxsvr_pkg_names = ['zabbix-server', 'zabbix-server-pgsql']
        }
        'sqlite': {
            $zbxsvr_pkg_names = ['zabbix-server', 'zabbix-server-sqlite3']
        }
        default: {
            $zbxsvr_pkg_names = ['zabbix-server']
        }
    }

    package { zabbix-server:
        name => $zbxsvr_pkg_names,
        ensure => installed,
    }

    service { zabbix-server:
        enable => true,
        ensure => running,
        hasrestart => true,
        hasstatus => true,
    }

}
