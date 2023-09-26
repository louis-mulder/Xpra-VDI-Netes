#!/bin/bash
#
# Louis Mulder Feb. 2020
# Updated: 26/11/2020
# Updated: 11/08/2022
# Xpra is released under the terms of the GNU GPL v2, or, at your option, any
# later version. See the file COPYING for details.
#
# Startup xpra as via session files
#                 etc......
#---------------------------------------------------------------
#
XPRA_TOPDIR_INT=${XPRA_TOPDIR_INT:-/srv}
export XPRA_TOPDIR_INT

U_USER=`id -un ${U_UID}`

[ -f /run/nologin ] && rm /run/nologin

EMPTY=/tmp/empty${$} ; export EMPTY

mkdir -p  ${EMPTY} 
#
[ ! -d /var/log/. ] && mkdir -p /var/log/.
#
if [ -d ${XPRA_TOPDIR_INT}/log/. ]
then
   if [ -d ${XPRA_TOPDIR_INT}/log/${HOSTNAME}/. ]
   then
	   :
   else
    mkdir -p ${XPRA_TOPDIR_INT}/log/${HOSTNAME}/.
    cd ${XPRA_TOPDIR_INT}/log/${HOSTNAME}/.
    [ -f /var/xpra/var.tar ] && tar xf /var/xpra/var.tar
   fi
   mv /var/log /var/NOT-USED
   cd /var
   ln -s ../${XPRA_TOPDIR_INT}/log/${HOSTNAME} log
fi
#
#
startup_rc () {
cd /tmp
for exe in ${XPRA_TOPDIR_INT}/etc/rc1.d/S*.sh
do
  [ -x ${exe} ] && ${exe}
done
cd -
}
#
shutdown_rc () {
cd /tmp
for exe in ${XPRA_TOPDIR_INT}/etc/rc1.d/K*.sh
do
  [ -x ${exe} ] && ${exe}
done
cd -
}



#
# If running with a home-dir which is ephemeral before shutting down save current X config data.
# For example running in highy secured environments
#

save_state () {
  FS=`set  -- \`df -k ${U_HOME}/. | expand | sed -e  '/[Ff][Ii][Ll][Ee][Ss][Yy][Ss][Tt][Ee][Mm].*/d'\` ;\
      shift \`expr ${#} - 1 \` ; echo ${1}`

    if [ "${FS}" = '/' -a -d ${XPRA_TOPDIR_INT}/save-states/. ]
    then
      if [ -d "${U_HOME}/." ]
      then
        DEST_DIR="${XPRA_TOPDIR_INT}/save-states/`hostname`--${NAMESPACE}"
        [ ! -d "${DEST_DIR}/." ] && mkdir -p "${DEST_DIR}" 2> /dev/null
        ( cd ${U_HOME}/. ; tar cf - .??* ) | ( cd ${DEST_DIR}/. ; gzip -c > hme-dir.gz)
        chown root:root  ${DEST_DIR}/hme-dir.gz
        chmod 600 ${DEST_DIR}/hme-dir.gz
       fi
    fi
}

restore_state () {
     FS=`set  -- \`df -k ${U_HOME}/. | expand | sed -e  '/[Ff][Ii][Ll][Ee][Ss][Yy][Ss][Tt][Ee][Mm].*/d'\` ;\
      shift \`expr ${#} - 1 \` ; echo ${1}`

    if [ "${FS}" = '/' -a -d ${XPRA_TOPDIR_INT}/save-states/. ]
    then
      DEST_DIR="${XPRA_TOPDIR_INT}/save-states/`hostname`--${NAMESPACE}"
      if [ -d "${U_HOME}/." ]
      then
       if [ -f ${DEST_DIR}/hme-dir.gz ]
       then
           (cd ${DEST_DIR}/. ; gzip -d -c < hme-dir.gz) | ( cd ${U_HOME}/. ; tar xf -)
       fi
      fi
    fi
}


trap "[ -d ${EMPTY} ] && rm -rf ${EMPTY};[ -f /run/xpra/Xpra_*.pid ] && kill -SIGTERM `[ -f /run/xpra/Xpra_*.pid ] && cat /run/xpra/Xpra_*.pid`; [ -f /run/xpra/Xpra_*.pid ] && rm -rf /run/xpra/Xpra_*.pid ; save_state ; shutdown_rc" 2 3 1
#

startup_rc
[ ! -d /etc/xpra/user-certs/. ] && mkdir -p /etc/xpra/user-certs/.
if [ -d /etc/xpra/user-certs/. ]
then
    mkdir /etc/xpra/user-certs/${HOSTNAME}
    cp /etc/xpra/*.pem /etc/xpra/user-certs/${HOSTNAME}/.
    chown -R ${U_UID}:${U_GID} /etc/xpra/user-certs/${HOSTNAME}/.
fi
    

ERR=0
HOSTNAME=`hostname` ;export HOSTNAME

#
cd /etc
rm -f localtime
ln -s ../usr/share/zoneinfo/Europe/Amsterdam localtime
cd 
OLDPWD=`pwd`
if [ "${PASSWD_ENTRY}" != '' ]
then

     EMPTY=/tmp/pwd${$}
     mkdir -p ${EMPTY}
     eval `(cd ${EMPTY} ;IFS=\:
             set -- ${PASSWD_ENTRY}
             echo "U_USER=${1}"
             echo "U_UID=${3}"
             echo "U_GID=${4}"
             echo "U_GECOS='${5}'"
             echo "U_HOME=${6}"
             echo "U_SHELL=${7}"
            )`
     rmdir ${EMPTY}
fi

export U_USER U_UID U_GID U_GECOS U_HOME U_SHELL

echo U_USER ${U_USER} 1>&2

# Check if homedirs etc. are created otherwise force them to create

    if [ "${U_HOME}" != '' -a ! -d "${U_HOME}"/. ]
    then
     mkdir -p "${U_HOME}"
     if [ -d /etc/skel/. ]
     then
	(cd /etc/skel/.; tar cf - . ) |(cd "${U_HOME}"/. ; tar vf -)
     fi
     chown -R ${U_UID} "${U_HOME}"/.
     chgrp -R ${U_GID} "${U_HOME}"/.
    fi

    if getent group ${U_GID} 1> /dev/null 2> /dev/null
    then
      :
    else
      echo "${U_USER}:x:${U_GID}:" >> /etc/group
      sed -i -e '/^$/d' /etc/group
    fi
    # example lmulder:*:545400007:/browers:*:545400006:lmulder,testuser1,testuser2 -- separator is a '/'
    # Don't use a '/' in a groupname, btw. it will also gives problems in a Unix env.
    (
    IFS='/'
    set -- ${GROUP_ENTRIES} 
    while [ "${1}" != '' ]
    do
       txt="${1}"
       (
       IFS=\:
       set -- ${txt}
       if [ "${txt}" != '' ] && getent group ${1} > /dev/null
       then
          useradd -G ${1} ${U_USER} 2> /dev/null
       else
          echo "${txt}" >> /etc/group
       fi
       )
    shift
    done
    )

    XDG_CONFIG_HOME=${U_HOME}/.${HOSTNAME:-unknown}
    export XDG_CONFIG_HOME
    mkdir -p ${XDG_CONFIG_HOME}
    chown -R ${U_UID}:${U_GID} ${XDG_CONFIG_HOME}/.

restore_state 

mkdir -p /run/user/${U_UID}/xpra 


mkdir -p ${XDG_CONFIG_HOME}/. /etc/ssh/. \
         /run/user/${U_UID} /run/xpra /var/run/pulse 2> /dev/null

chown -R ${U_UID}:${U_GID} ${XDG_CONFIG_HOME}/. /etc/ssh/. \
                           /run/user/${U_UID} /run/xpra /var/run/pulse

XSESSION=${XSESSION:-seamless}
RC=0

mkdir -p /tmp/.ICE-unix /tmp/.X11-unix 2> /dev/null
chmod 1777 /tmp/.X11-unix /tmp/.ICE-unix

if [ "${U_UID}" != '' -a "${U_UID}" != 0 ]
then
  STARTUP_XPRA="${XPRA_TOPDIR_INT}/xsession/xpra_startup_${XSESSION}.sh"
 if [ ! -x ${STARTUP_XPRA} ] 
  then
     echo "Can't find xpra-startup file or is not executable '${STARTUP_XPRA}'"
     RC=1
 fi
      exec 2> /dev/null
      exec 1> /dev/null
      exec 0< /dev/null
      ${STARTUP_XPRA} "${XPRA_OPTIONS}"
      RC=${?}
      save_state
else
   echo "Xpra not allowed to run under root-privileges or user ${U_USER} not found"
   RC=2
fi
echo "Xpra Stopped ${RC}"
exit ${RC}
