#!/bin/bash
#
# Startup sshd-container
# 
XPRA_TOPDIR_INT=${XPRA_TOPDIR_INT:-/srv}
export XPRA_TOPDIR_INT
PATH=${XPRA_TOPDIR_INT}/bin:/usr/bin:/sbin:${PATH}:/usr/local/sbin:/usr/local/bin
export PATH

if [ -f /etc/resolv.conf -a "${SEARCH_DOMAINS}" != '' ]
then
    TO_SEARCH="${SEARCH_DOMAINS}"
    SEARCH_STR=`set -- \`grep '^search' < /etc/resolv.conf\` ; [ "${1}" != '' ] && shift 1; echo ${*}`
    if [ "${SEARCH_STR}" != '' ]
    then
         for search in ${SEARCH_STR}
         do
            case "${TO_SEARCH}" in
            *" ${search}"* | *" ${search} "* | "${search} "* ) 
             :
            ;;
            * )
               TO_SEARCH="${TO_SEARCH:+${TO_SEARCH} ${search}}"
               TO_SEARCH="${TO_SEARCH:-${search}}"
            ;;
            esac
         done
     cp /etc/resolv.conf /tmp
     sed -i /tmp/resolv.conf -e 's/search .*/search '"${TO_SEARCH}"'/'
     cp /tmp/resolv.conf /etc/resolv.conf
     rm /tmp/resolv.conf
    fi
fi

[ ! -d /etc/user-certs/. ] && mkdir -p /etc/user-certs/. && chmod 1777 /etc/user-certs/.

    if cd /${XPRA_TOPDIR_INT}/etc/rc1.d/. 
    then
      set -- S[0-9][0-9]*.sh
      while [ -x ${1} -a ${#} -gt 1 ]
      do
        ./${1}
        shift
      done
# 
# The last one run with PID 1
#
    rm -rf /run/nologin 2> /dev/null
    exec ./${1}
    fi
