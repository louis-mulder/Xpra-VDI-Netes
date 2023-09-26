#!/bin/bash

PATH=/sbin:/usr/sbin:${PATH}
export PATH

if [ -f /run/oddjobd.pid ]
then
  if ps `cat /run/oddjobd.pid` > /dev/null 2>&1
   then
   :
   else
    rm /run/oddjobd.pid
    oddjobd -p /var/run/oddjobd.pid
  fi
else
   mkdir -p /var/run/ 2> /dev/null
   oddjobd -p /var/run/oddjobd.pid &
fi
