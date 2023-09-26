#!/bin/bash
#
# Modify /etc/avahi/avahi-daemon.conf so it it uses only device net1
#
#
# Startup avahi
#

PID=`cat /run/avahi-daemon/pid 2> /dev/null`

if [ "${PID}" != '' ]
then
 if ps ${PID} > /dev/null 2>/dev/null
 then
  :
 else
   [ -f /run/avahi-daemon/pid ] && rm /run/avahi-daemon/pid
   mkdir -p /run/avahi-daemon 2>/dev/null
   avahi-daemon -D --no-rlimits
 fi
else
   [ -f /run/avahi-daemon/pid ] && rm /run/avahi-daemon/pid
   mkdir -p /run/avahi-daemon 2>/dev/null
   avahi-daemon -D --no-rlimits
fi
