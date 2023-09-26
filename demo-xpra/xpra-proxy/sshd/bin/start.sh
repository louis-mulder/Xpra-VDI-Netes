#!/bin/bash

#sleep 3600

PATH=/srv/bin:${PATH}
export PATH

if [ ! -f /etc/ssh-keys/id-rsa ]
then
while true
do
   echo
done | ssh-keygen -f /etc/ssh-keys/id-rsa -t rsa -b 4096 
fi

mkdir -p /run/etc/ssh-keys 2> /dev/null

if cd /srv/etc/rc1.d
then
       if [ -f /etc/pam.d/common-session ]
       then
         if egrep 'session optional pam_oddjob_mkhomedir.so' < /etc/pam.d/common-session 2> /dev/null 1>&2
         then
          :
         else
           sed -i -e '/pam_systemd.so/isession optional pam_oddjob_mkhomedir.so\n'  /etc/pam.d/common-session
         fi
       fi

     [ -f /etc/ipa/ca.crt ] &&  chmod 644 /etc/ipa/ca.crt

     set -- S[0-9][0-9]*.sh
     while [ ${#} -gt 1 ]
     do
	[ -x ./${1} ] && ./${1} start
	shift
     done

     [ -x ./${1} ] &&  exec ./${1} start

fi
sleep 36000
