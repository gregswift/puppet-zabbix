# == Define: zabbix::config
#
# Edit a setting in a zabbix config file.
#
# === IMPORTANT
# You should not use this resource directly.  Use these:
#
#    zabbix::agent::config
#    zabbix::server::config
#    zabbix::proxy::config
#
#
# === Parameters
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
# [*value*]
# String. The value to set the config item to.
#
# [*type*]
# String. Has to be either 'server', 'proxy' or 'agent'.
#
# [*context*]
# String. The path to the zabbix config file you want to edit.
#
# === Examples
#
# * Shorten the cache timeout
#
# zabbix::config { 'agent-timeout':
#   value => '60',
#   type  => 'agent',
# }
#
# * Remove the cache timeout setting
#
# zabbix::config { 'agent-timeout':
#   ensure => absent,
#   type   => 'agent',
# }
#
#
define zabbix::config (
  $ensure  = present,
  $value,
  $type,
  $context,
) {

### Validate parameters

## ensure
  if ! ($ensure in [ present, absent ]) {
    fail("'${ensure}' is not a valid ensure parameter value")
  }
  if $ensure == present {
    $onlyif  = "match ${title}[.='${value}'] size == 0"
    $changes = "set ${title} ${value}"
  } else {
    $onlyif  = "match ${title}[.='${value}'] size != 0"
    $changes = "rm ${title}"
  }

## type
  if ! ($type in [ 'server','proxy','agent' ]) {
    fail("'${type}' is not a valid type parameter value")
  }

## context
  if $context == undef {
    fail("'${type}' is not a valid context parameter value")
  }

### Logic

  augeas { "zabbixconf.${type}.${title}":
    context => $context,
    onlyif  => $onlyif,
    changes => $changes,
  }

}
