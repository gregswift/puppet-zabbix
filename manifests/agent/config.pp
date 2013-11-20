
# == Define: zabbix::agent::config
#
# Edit a setting in a zabbix agentd config file.  If you want to edit
# the zabbix_agent.conf instead just change the context when you call
# this resource
#
#
# === Title
# The title you provide should match the configuration parameter
# you are trying to configure.
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
# String. Contains the value you would like the configuration parameter
# to be set to.
#
# === Examples
#
# * Shorten the cache timeout
#
# zabbix::agent::config { 'timeout': value => '60' }
#
# * Remove the cache timeout setting
#
# zabbix::agent::config { 'timeout': ensure => absent }
#
#
# [ NO empty lines allowed between this and definition below for rdoc ]
define zabbix::agent::config (
  $ensure  = present,
  $value   = undef,
  $context = '/etc/zabbix_agentd.conf',
) {

  zabbix::config { $title:
    ensure   => $ensure,
    value    => $value,
    type     => 'agent',
    context  => $context,
  }

}
