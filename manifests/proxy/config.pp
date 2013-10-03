
# == Define: zabbix::proxy::config
#
# Edit a setting in a zabbix proxy config file
#
#
# === IMPORTANT
#
# You must add any file you want to reference into modules/sudo/files
# other wise any call to this definition will fail.
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
# [*type*]
# String. Has to be either 'server', 'proxy' or 'proxy'
#
# === Examples
#
# * Shorten the cache timeout
#
# zabbix::proxy::config { 'timeout': value => '60' }
#
# * Remove the cache timeout setting
#
# zabbix::proxy::config { 'timeout': ensure => absent }
#
#
# [ NO empty lines allowed between this and definition below for rdoc ]
define zabbix::proxy::config (
  $ensure  = present,
  $value,
) {

  zabbix::config { $title:
    ensure   => $ensure,
    value    => $value,
    $type    => 'proxy',
    $context => '/etc/zabbix_proxy.conf'
  }
}
