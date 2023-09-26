#!/bin/bash

[ ! -d /run/dbus ] && mkdir -p /run/dbus

PS_STR=`ps -eaf | egrep 'messag.*/usr/bin/dbus-daemon.*--system' |grep -v grep 2> /dev/null`

if [ "${PS_STR}" = '' ]
then
    [ -f /run/dbus/pid ] && rm /run/dbus/pid
    dbus-uuidgen > /var/lib/dbus/machine-id
    dbus-daemon --system 
fi



