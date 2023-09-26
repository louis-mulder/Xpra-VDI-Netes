#!/bin/bash

HOSTNAME=`hostname`

IP_ADDRESSES=`ip a | sed -e '/inet[[:space:]]/!d' \
	           -e '/inet[[:space:]][[:space:]]*127..*/d' \
           	   -e 's/[[:space:]]*inet[[:space:]]*//' \
		   -e 's%/..*%%'`

SUBJECTALTNAME="DNS:${HOSTNAME}"

for ip in ${IP_ADDRESSES}
do
  SUBJECTALTNAME="${SUBJECTALTNAME}, IP:$ip"
done

CERTS_SUBDIR=${HOSTNAME}

if [ "${XPRA_MODE}" != '' -a "${XPRA_MODE}" = 'proxy' ]
then
   DAYS=3650
   mkdir -p /etc/xpra 2> /dev/null
else
   mkdir -p /etc/xpra 2> /dev/null
   DAYS=365
fi


   if cd /etc/xpra
   then
         openssl req -new -newkey rsa:4096 -days ${DAYS} -nodes -x509 \
                     -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost" \
                     -keyout "key.pem" -out "cert.pem"
   fi

   cat cert.pem key.pem  > ssl-cert.pem
