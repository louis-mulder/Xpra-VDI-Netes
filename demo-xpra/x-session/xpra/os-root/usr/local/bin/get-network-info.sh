#!/bin/bash
get-info () {
(
cat <<EOB
import socket
import sys
port=0
while port < 2048:
   s=socket.socket()
   s.bind(("", 0))
   port = s.getsockname()[1]
   s.close()
print(port)
sys.stdout.flush()
EOB
) | python3 -
}
set -- `cd /sys/class/net/ ; echo * `

while [ "${1}" != '' ]
do
    if [ "${1}" != 'lo' ] 
     then
       case ${1} in
       #(
         eth0 )
             ADDR=`ip -4 a show ${1}  | sed  -e '/valid_lft/,$d'  | \
             sed  -e '/ inet/!d' -e 's%/..*%%' -e 's%^  *inet. *%%'`
             K8_IP_ADDR=${ADDR:-UNKNOWN}
       ;;
         net1 )
             ADDR=`ip -4 a show ${1}  | sed  -e '/valid_lft/,$d'  | \
             sed  -e '/ inet/!d' -e 's%/..*%%' -e 's%^  *inet. *%%'`
             IP_ADDR=${ADDR:-UNKNOWN}
       ;;
       esac
    fi
    shift
done 
echo K8_IP_ADDR=${K8_IP_ADDR}\;IP_ADDR=${IP_ADDR}
