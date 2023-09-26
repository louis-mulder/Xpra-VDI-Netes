#!/bin/bash

# Louis Mulder May-2023
#
# Startup xinetd
# If it is running for the CMS Ansible container it's configure
# /etc/environment and xinetd will run in the foreground.
#
# In the xsession-container it forks itself to the background.
#

if [ ! -f /etc/xinetd.d/rsh-server ]
then
(
cat <<EOF
service shell
{
         disable         = no
         flags           = REUSE
         socket_type     = stream
         wait            = no
         user            = root
         server          = /usr/sbin/in.rshd
         log_on_failure  += USERID
         log_on_success  += PID HOST EXIT
}
EOF
) > /etc/xinetd.d/rsh-server
fi

if [ -d /root/.kube/. ]
then

	mkdir -p /etc/kube
	cp /root/.kube/config /etc/kube
	chmod 555 /etc/kube
	chmod 444 /etc/kube/config
	KUBECONFIG=/etc/kube/config
	export KUBECONFIG

	(
	echo "PATH=/usr/local/bin:${XPRA_TOPDIR_INT:-/srv}/bin:${PATH}"
	echo KUBECONFIG=/etc/kube/config
	) >> /etc/environment
	OPTION='-dontfork'
else
        OPTION=''
fi

exec xinetd ${OPTION}
