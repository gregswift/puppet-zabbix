# = Class: zabbix::proxy
#
# Configure a proxy system
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
#
# == Examples
#
# * Configure zabbix proxy to use a postgres db backend
# _Note that several of these parameters are defaults._
#
#   class { 'zabbix::proxy':
#       database   => 'pgsql',
#   }
#
#
class zabbix::proxy (
  $database         = 'pgsql',
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
