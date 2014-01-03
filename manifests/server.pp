# = Class: zabbix::server
#
# Configure a server, currently consolidated web+collector
#
#
# == IMPORTANT
#
# Currently you have to manually setup your database and import the schemas.
#
# == Parameters
#
# [*ensure*]
# String. Controls if the managed resources shall be <tt>present</tt> or
# <tt>absent</tt>. If set to <tt>absent</tt>:
# * The managed software packages are being uninstalled.
# * Any traces of the packages will be purged as good as possible. This may
# include existing configuration files. The exact behavior is provider
# dependent. Q.v.:
# * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
# * {Puppet's package provider source code}[http://j.mp/wtVCaL]
# * System modifications (if any) will be reverted as good as possible
# (e.g. removal of created users, services, changed log settings, ...).
# * This is thus destructive and should be used with care.
# Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
# Boolean.  Whether or not to make sure that packages are always at latest version.
#
# [*version_modifier*]
# String. For RHEL-based distros, versions of zabbix include a periodless modifier to the name.
#
# [*database*]
# String. What database backend to work with. Typically 'mysql' or 'pgsql'
#
# [*dbhost*]
# String. The IP or FQDN of the database server.
#
# [*dbname*]
# String. The IP or FQDN of the database server.
#
# [*dbuser*]
# String. The database username for the Zabbix database.
#
# [*dbpassword*]
# String. Password for database user.
#
# [*users*]
# Array. List of users to enable in Zabbix UI.  Specifically for 
#
# [*endpoint*]
# String. API endpoint for zabbix web UI for enabling $users
#
#
# == Examples
#
# * Configure zabbix server to use a postgres db backend
# _Note that several of these parameters are defaults._
# 
#   class { 'zabbix::server':
#       database   => 'pgsql',
#       dbname     => 'zabbix',
#       dbuser     => 'zabbix',
#       dbpassword => 'mypasswordgoeshere',
#       users      => ['sue', 'bob'],
#   }
#
#
class zabbix::server (
  $ensure           = present,
  $autoupgrade      = false,
  $version_modifier = '20',
  $database         = 'pgsql',
  $dbhost           = 'localhost',
  $dbname           = 'zabbix',
  $dbuser           = 'zabbix',
  $dbpassword,
  $users,
  $endpoint,
) {

    $packages = [ "zabbix${version_modifier}-server",
                  "zabbix${version_modifier}-server-${database}",
                  "zabbix${version_modifier}-web-${database}"
    ]

    package { $packages:
        ensure => latest,
    }

    service { 'zabbix-server':
        enable     => true,
        ensure     => running,
        hasrestart => true,
        hasstatus  => true,
    }

    # TODO: check to see if Service['httpd'] is defined before doing this
    service { 'httpd':
        ensure     => running,
        hasrestart => true,
        hasstatus  => true, 
    }

    file { "/etc/httpd/conf.d/zabbix.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[$packages],
        content => template('zabbix/zabbix.conf.erb'),
        notify  => Service['httpd'],
    }
    file { "/var/www/html/index.php":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[$packages],
        content => template('zabbix/index.php.erb'),
    }
    file { "/usr/share/zabbix/images/general/zabbix.png":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[$packages],
        content => template('zabbix/zabbix.png'),
    }
    file { "/etc/zabbix_server.conf":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[$packages],
        content => template('zabbix/zabbix_server.conf.erb'),
        notify  => Service['zabbix-server'],
    }
    file { "/etc/zabbix/web/zabbix.conf.php":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[$packages],
        content => template('zabbix/zabbix.conf.php.erb'),
        notify  => Service['httpd'],
    }

    zabbix_syncusers($users, $endpoint)
}
