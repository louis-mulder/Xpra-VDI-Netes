#!/bin/bash
#
PATH=/usr/bin:/sbin:${PATH}:/usr/local/sbin:/usr/local/bin
export PATH

if [ -d "${XPRA_TOPDIR_INT:-/srv}/ansible/xpra-proxy/." ]
then
    for yml in ${XPRA_TOPDIR_INT:-/srv}/ansible/xpra-proxy/*.yaml
    do
        ansible-playbook ${yml}
    done
fi

#sleep 3600
