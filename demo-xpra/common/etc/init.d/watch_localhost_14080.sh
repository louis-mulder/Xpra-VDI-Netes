#!/bin/bash
#exit 0
XPRA_TCP_PORT=14080 ; export XPRA_TCP_PORT
# 
# When xinetd not more active is on session container
# Send a kill to all running processes
(
cat <<EOB
#!/bin/bash
#
# Wait until xpra is fully started up
# Xpra downloading can take some time
# 
sleep 30
ITRY=0
MAXTRY=400
TIMEOUT=10
timeout 2 bash -c "</dev/tcp/localhost/${XPRA_TCP_PORT}" 1> /dev/null  2> /dev/null 
#
while [ \${?} != 0 -a \${ITRY} -le \${MAXTRY} ]
do
   sleep \${TIMEOUT}
   ITRY=\`expr \${ITRY} + 1\`
   [ \${TIMEOUT} -gt 1 ] && TIMEOUT=\`expr \${TIMEOUT} - 1\`
   bash -c "</dev/tcp/localhost/${XPRA_TCP_PORT}"  2> /dev/null 1> /dev/null
done
#
while true
do
bash -c "</dev/tcp/localhost/${XPRA_TCP_PORT}"  2> /dev/null
if [ "\${?}" != 0 ]
 then
  sleep 2
  timeout 2 bash -c "</dev/tcp/localhost/${XPRA_TCP_PORT}"  2> /dev/null
  if [ "\${?}" != 0 ] 
   then
     if cd \${XPRA_TOPDIR_INT:-/srv}/pre-watch/.
     then 
        for pre in [0-9][0-9]*.sh
         do
           [ -x ${pre} ] && ./\${pre}
         done
     fi
     kill 1 1>&2
  fi
else
  sleep 5
fi
done
EOB
)  > /run/watch-${XPRA_TCP_PORT}
chmod 755 /run/watch-${XPRA_TCP_PORT} 
cd /tmp
nohup /run/watch-${XPRA_TCP_PORT}  >/dev/null 2>&1 &
