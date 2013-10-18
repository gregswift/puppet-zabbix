class zabbix {
# Not Sure why this is here ?
#    package { zabbix:
#        ensure => installed
#    }

#    augeas { 'zabbix-agent':
#        context =>  '/files/etc/services',
#        changes => [
#            "ins service-name after service-name[last()]",
#            "set service-name[last()] zabbix-agent",
#            "set service-name[. = 'zabbix-agent']/port 10050",
#            "set service-name[. = 'zabbix-agent']/protocol tcp",
#            "ins service-name after /files/etc/services/service-name[last()]",
#            "set service-name[last()] zabbix-agent",
#            "set service-name[. = 'zabbix-agent'][2]/port 10050",
#            "set service-name[. = 'zabbix-agent'][2]/protocol udp",
#        ],
#        onlyif => "match service-name[port = '10050'] size == 0",
#    }

}

