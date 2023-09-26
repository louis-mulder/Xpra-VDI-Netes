#!/bin/bash

exec 2> /srv/start.log
set -x

XPRA_TOPDIR_INT=${XPRA_TOPDIR_INT:-/srv}
export XPRA_TOPDIR_INT

ROOT_DIRS='root os-root'
for d in ${ROOT_DIRS}
do
  
if cd ${XPRA_TOPDIR_INT}/${d}/.  2>/dev/null
then
	tar cf - .  | (cd / ; tar xf - )
fi

done

     if [ -f /etc/ssh/sshd_config ]
     then

        sed -i -e 's/\([Ss][Uu][Bb][Ss][Yy][Ss][Tt][Ee][Mm]..*[Ss][Ff][Tt][Pp]\)/#\1/'\
               -e 's/#AuthorizedKeysFile/AuthorizedKeysFile/' \
               -e 's%AuthorizedKeysFile%AuthorizedKeysFile  /run/etc/ssh-keys/authorized_keys %'  \
	       -e '$aPermitOpen 127.0.0.1:14080 localhost:14080' /etc/ssh/sshd_config 

              if [ "${PASSWD_ENTRY}" != '' ]
              then
               eval `(
                            EMPTY=\`mktemp -d\`
                            cd ${EMPTY}
                            IFS=':'
                            set -- ${PASSWD_ENTRY}
                            [ "${1}" != '' ] &&
                            echo "AllowUsers ${1}" >> /etc/ssh/sshd_config
                            rmdir ${EMPTY}
                            echo UID_GID="'${3}:${4}'"
                     )`
              fi
          if [ ! -f  /run/etc/ssh-keys/authorized_keys ]
          then
             mkdir -p  /run/etc/ssh-keys 2> /dev/null
             cat /etc/ssh-keys/id-rsa.pub >>  /run/etc/ssh-keys/authorized_keys
             cp  /etc/ssh-keys/id-rsa  /run/etc/ssh-keys/id-rsa
             [ "${UID_GID}" != '' ] && chown /run/etc/ssh-keys/id-rsa && chmod 600 /run/etc/ssh-keys/id-rsa
          fi
     fi 

      if [ -f /etc/pam.d/common-session ]
      then
         if egrep 'session..*optional..*pam_oddjob_mkhomedir.so' < /etc/pam.d/common-session 2> /dev/null 1>&2
         then
          :
         else
           sed -i -e '/pam_systemd.so/isession optional pam_oddjob_mkhomedir.so\n'  /etc/pam.d/common-session
         fi
      fi

     if [ -f /etc/sssd/sssd.conf ]
      then
       if egrep 'override_shell..*=..*/srv/sbin/xpra_x-session' < /etc/sssd/sssd.conf 2> /dev/null 1>&2
       then
          :
       else
	 sed -i -e '/\[[Dd][Oo][Mm][Aa][Ii][Nn]..*/aoverride_shell = /srv/sbin/xpra_x-session\noverride_homedir = /tmp/%u'\
	                            /etc/sssd/sssd.conf
       fi
     fi

if cd ${XPRA_TOPDIR_INT}/etc/rc1.d
then
     

     set -- S*.sh

     case ${1} in
     *copyfromroot* ) shift
     ;;
     esac

     while [ ${#} -gt 1 ]
     do
        echo Starting ${1} 
	[ -x ./${1} ] && ./${1} start
	shift
     done
     
     [ -x ./${1} ] &&  exec ./${1} start

fi

#sleep 36000
