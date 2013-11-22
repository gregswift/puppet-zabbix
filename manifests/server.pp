class zabbix::server (
  $database = 'pgsql',
  $version_modifier = '20',
  $dbhost = '',
  $dbpassword = '',
  $dbuser = '',
  $dbname = '',
  $users = '', 
) inherits zabbix {

    $zbxsvr_pkg_names = ["zabbix${version_modifier}-server", "zabbix${version_modifier}-server-${database}", "zabbix${version_modifier}-web-${database}"]

    package { $zbxsvr_pkg_names:
        ensure => latest,
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
   $endpoint = "${::env}-${::region}-${::dc}"
   zabbix_syncusers($users,$endpoint)
}
