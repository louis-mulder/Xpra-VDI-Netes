#!/bin/bash

# 
# Get ip-address on net1
#
DEVICE=${DEVICE:-`basename \`basename $0 .sh\` _get_ip`}
#
IP_ADDR=''
ITRY=0
MAX_ITRY=15

while [ "${IP_ADDR}" = '' -a ${ITRY} -lt ${MAX_ITRY} ]
do
eval `if NIC_OUT=\`ip addr show ${DEVICE} 2> /dev/null\`
then
    echo "${NIC_OUT}" | sed -e '/^ *inet  */!d' \
	                    -e 's%/.*$%%' \
			    -e 's/  *inet */IP_ADDR=/'


fi`
if [ "${IP_ADDR}" != '' ] 
then
   exec echo "${IP_ADDR}"
fi
sleep 0.6
ITRY=`expr ${ITRY} + 1`
done

#
# No extra network so use the cluster-network
#
   DEVICE='eth0' ; export DEVICE
   exec ${0}
