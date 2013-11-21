class zabbix::server (
  $database = undef,
  $version_modifier = '20',
  $credentialid = '',
  $projectid = '',
) inherits zabbix {
    include passwordsafe
    $dbpassword = pwsafe_lookup($projectid, $credentialid, 'password')
    $dbuser = pwsafe_lookup($projectid, $credentialid, 'username')
    # url should look like: http://dbinfra-n01.staging.ord1.us.ci.rackspace.net/zabbix_staging_us
    # next line splits the url string into hostname and dbname.
    $host_parts = split(regsubst(pwsafe_lookup($projectid, $credentialid, 'url'),'^http://',''),'/')
    $dbhost = $host_parts[0]
    $dbname = $host_parts[1]

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
