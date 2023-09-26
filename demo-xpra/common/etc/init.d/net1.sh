#!/bin/bash
#
# Startup dhclient on net1 device provided by multus
# Startup avahi-daemon
#
NETDEVICE=`expr "${0}" : '[\./[A-Za-z0-9][\./[A-Za-z0-9]*[Ss][0-9][0-9]*\(.*\)\..*'`
#
if [ "${NETDEVICE}" != '' -a -d /sys/class/net/${NETDEVICE} ]
then
#
startup_dhclient () {
(
cat <<EOB 
interface net1 {
send host-name = gethostname();
request subnet-mask, broadcast-address, time-offset,
        domain-name, domain-name-servers, domain-search, host-name,
        dhcp6.name-servers, dhcp6.domain-search, dhcp6.fqdn, dhcp6.sntp-servers,
        netbios-name-servers, netbios-scope, interface-mtu,
        rfc3442-classless-static-routes, ntp-servers;
}
EOB
) | dhclient -nw -cf -
}
if ip a show ${NETDEVICE} | expand | egrep '[Ii][Nn][Ee][Tt] '  > /dev/null 2>&1
then
   [ "`ip a show net1 | expand | sed -e '/inet /!d' -e 's/^ *inet *//' -e 's%/.*%%'`" != '' ] && exit 0
   PID=`cat /run/dhclient.pid 2> /dev/null`
   if [ "${PID}" != '' ]
   then
     exec echo dhclient already active with pid `cat /run/dhclient.pid` on device ${NETDEVICE} 1>&2
   else
     exec echo IP-address already obtained from DHCP server 1>&2
   fi
else
   startup_dhclient
fi
fi
