#!/bin/bash
SRC_PORT=${SRC_PORT:-14500}
cnt=0
IPTABLES_LINES=`iptables -L INPUT --line-numbers | egrep -i '[ds]pt.*'"${SRC_PORT}"|sed 's/\(^[0-9][0-9]*\)\(.*$\)/\1/g'`
#
for l in ${IPTABLES_LINES}
do
  iptables -D INPUT `expr ${l} - ${cnt}`
  cnt=`expr ${cnt} + 1`
done
#
IPTABLES_LINES=${IPTABLES_LINES:-`iptables -L INPUT --line-numbers | egrep -i 'REJECT.*all' |sed 's/\(^[0-9][0-9]*\)\(.*$\)/\1/g'`}
IPTABLES_LINES=${IPTABLES_LINES:-`expr \`iptables -L INPUT --line-numbers | wc -l |sed 's/\(^[0-9][0-9]*\)\(.*$\)/\1/g'\` - 1`}
#

for addr in ${*}
do
 for port in ${SRC_PORT} 14443
 do
 if [ "${IPTABLES_LINES}" != '' ] 
 then
   cnt=`set -- ${IPTABLES_LINES} ; echo ${1}`
   iptables -I INPUT ${cnt} -p tcp -s ${addr} --dport ${port} -j ACCEPT
   cnt=`expr ${cnt} + 1`
   iptables -I INPUT ${cnt} -p tcp -s ${addr} --sport ${port} -j ACCEPT
   IPTABLES_LINES=`set -- ${IPTABLES_LINES}; shift`
 fi
 done
done

