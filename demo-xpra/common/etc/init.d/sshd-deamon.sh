#!/bin/bash

[ ! -d /run/sshd ] && mkdir -p /run/sshd
[ -f /run/nologin ] && rm /run/nologin

KEYS=`cd /etc/ssh ; echo ssh_host_*`

[ "${KEYS}" = 'host_ssh_*' ] && ssh-keygen -A

exec /usr/sbin/sshd 
