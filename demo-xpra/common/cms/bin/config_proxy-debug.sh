#!/bin/bash
#
PATH=/usr/bin:/sbin:${PATH}:/usr/local/sbin:/usr/local/bin
export PATH

if [ -f "${XPRA_TOPDIR_INT:-/srv}/ansible/playbooks/sssd-debug.yaml" ]
then
    ansible-playbook "${XPRA_TOPDIR_INT:-/srv}/ansible/playbooks/sssd-debug.yaml"
fi

#sleep 3600
