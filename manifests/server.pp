class zabbix::server (
  $database = undef,
  $version_modifier = '',
  $dbhost = 'dbinfra-n01.staging.ord1.us.ci.rackspace.net',
  $dbname = 'zabbix',
  $dbuser = 'zabbix',
  $dbpassword = 'Swacr4d6',
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

    package { 'zabbix-server':
        name => $zbxsvr_pkg_names,
        ensure => installed,
    }

    service { 'zabbix-server':
        enable => true,
        ensure => running,
        hasrestart => true,
        hasstatus => true,
    }
    service { 'httpd':
        ensure => running,
        hasrestart => true,
        hasstatus => true, 
    }

   file { "/etc/httpd/conf.d/zabbix.conf":
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     require => Package[$zbxsvr_pkg_names],
     content => template('zabbix/zabbix.conf.erb'),
     notify  => Service['httpd'],
   }

   file { "/var/www/html/index.php":
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     require => Package[$zbxsvr_pkg_names],
     content => template('zabbix/index.php.erb'),
   }
   file { "/usr/share/zabbix/images/general/zabbix.png":
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     require => Package[$zbxsvr_pkg_names],
     content => template('zabbix/zabbix.png'),
   }   
   file { "/etc/zabbix_server.conf":
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     require => Package[$zbxsvr_pkg_names],
     content => template('zabbix/zabbix_server.conf.erb'),
     notify  => Service['zabbix-server'],
   }
   file { "/etc/zabbix/web/zabbix.conf.php":
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
     require => Package[$zbxsvr_pkg_names],
     content => template('zabbix/zabbix.conf.php.erb'),
     notify  => Service['httpd'],
   }
}
