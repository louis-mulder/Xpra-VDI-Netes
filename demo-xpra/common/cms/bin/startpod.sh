#!/bin/bash

ANSIBLE_PLAYBOOK='/srv/ansible/playbooks/demo-xpra-client.yaml'

U_USER="${1}"
shift
XPRA_OPTIONS=
IMAGE_SUFFIX='xfce4'
XPRA_PORT=14500
export XPRA_OPTIONS IMAGE_SUFFIX XPRA_PORT

get_free() {
(
cat <<EOB
import socket
port=0
while port < 2048:
   s=socket.socket()
   s.bind(("", 0))
   port = s.getsockname()[1]
   s.close()
print(port)
EOB
) | python3
}

[ ${#} -lt 1 ] && exit 1

 CMD=`echo "${@}" | sed -e 's%^%#%' \
                        -e 's/\\\$/'"'$'/"\
                        -e 's/^#//'`
set -- `eval echo ${CMD}`

get_session_or_start () {

  OUTPUT=`rsh -n -l ${U_USER} localhost ansible-playbook  \
         -e user=${U_USER} -e xsession=${xsession} \
         -e image_suffix=${image_suffix} \
         -e create_pod=${create_pod} \
         ${XPRA_OPTIONS:+-e xpra_options=\"${XPRA_OPTIONS}\"} \
         ${ANSIBLE_PLAYBOOK} 2>&1 | sed -e '/ERRMSG=/!d' \
                                        -e 's/^ *"//' \
                                        -e 's/"$//' \
                                        -e 's/'\''//g' \
                                        -e 's/"//g' `

      if [ "${OUTPUT}" != '' ]
      then
        set -- ${OUTPUT}
        while [ "${1}" != '' ]
        do
           case ${1} in
           #(
                *=* )
                      eval ${1}
                      shift ${#}
           ;;
           #(
                 * ) :
           ;;
           esac
           shift
        done
       fi
        
         
      if [ "${ERRMSG}" = '' ]
      then
         export USER IP_ADDR K8_IP_ADDR POD_NAME FREE_PORT NAMESPACE CONTAINER
      else
         echo "${ERRMSG}" | sed -e 's/\(.*\)\(\[\)//' -e 's/\(\]\)\(.*\)//'
         echo "${MSG}" 1>&2
         exit 1
      fi
}  

activate_ssh_proxy () {

    XSESSION=`echo ${POD_NAME} | sed -e 's/'"${U_USER}"'-//'`

    bash -c "</dev/tcp/${IP_ADDR}/${XPRA_PORT:-14500}" 2> /dev/null 1>/dev/null
     RC=${?}
     if [ ${RC} != 0 ]
     then
     ITRY=1
     while [ ${ITRY} -lt 100 -a ${RC} != 0 ]
     do
        ITRY=`expr ${ITRY} + 1`
        bash -c "</dev/tcp/${IP_ADDR}/${XPRA_PORT:-14500}" 2> /dev/null 1> /dev/null
        RC=${?}
        [ "${RC}" != 0 ] && sleep 2
     done
     fi



if [ "${K8_IP_ADDR}" != '' -a "${POD_NAME}" != '' ]
then
[ ! -d /home/${U_USER}/.ssh ] && mkdir -p /home/${U_USER}/.ssh 

echo exec cat /etc/ssh-keys/id-rsa | \
      rsh -l ${U_USER} localhost kubectl -n ${NAMESPACE} exec -i ${POD_NAME} --container sshd -- bash >  /home/${U_USER}/.ssh/id-rsa

chmod 700  /home/${U_USER}/.ssh
chmod 400  /home/${U_USER}/.ssh/id-rsa
exec 2> /dev/null
# 
# Check if there is already a ssh-tunnel active ?
#
SSH_PID=`ps -eaf | egrep "${U_USER}@${IP_ADDR}"' *-L *[0-9][0-9]*:localhost:14080 *-N'|grep -v grep`

if [ "${SSH_PID}" != '' ]
then
   FREE_PORT=`(
               set -- ${SSH_PID}
               while [ "${1}" != '-L' ]
                do
                  shift
                done
               shift
               IFS=':'
               set -- ${1}
               echo ${1}
              )`

   xpra detach tcp://localhost:${FREE_PORT}

else
   FREE_PORT=`get_free`
   ssh -f -o StrictHostKeychecking=no -i /home/${U_USER}/.ssh/id-rsa ${U_USER}@${IP_ADDR} -L ${FREE_PORT}:localhost:14080 -N
fi
exec echo "tcp://localhost:${FREE_PORT}"
else
echo "Failure can't find/create pod or ip-address" 1>&2
exit 1
fi
#)
}


 case ${1} in
 #(
     #echo*OSTYPE|\
     #command|\
     #command*xpra ) exec rsh -l ${U_USER} localhost ${@}
     #;;
 #(
     [Ss][Tt][Aa][Rr][Tt]* ) 
             create_pod='yes'
             case "${2}" in
             #(
              -*  ) shift_cnt=1
             ;;
             #(
              *  ) image_suffix=${2}
                   shift_cnt=2
             ;;
             esac
             case ${1} in
             #(
                 *[Dd][Ee][Ss][Kk][Tt][Oo][Pp] )
                 xsession='desktop'
                 shift_cnt=1
             ;;
             #(
                 *[Ss][Hh][Aa][Dd][Oo][Ww] ) 
                 create_pod='no'
                 xsession=''
                 shift_cnt=1
             ;;
             #(
                 [Ss][Tt][Aa][Rr][Tt] ) 
                 xsession='seamless'
                 shift_cnt=1
             ;;
             esac
 ;;
 #(
  [Pp][Rr][Oo][Xx][Yy] | _[Pp][Rr][Oo][Xx][Yy] | [Aa][Tt][Tt][Aa][Cc][Hh] ) 
             create_pod='no'
             case "${2}" in
             #(
              -*  ) shift_cnt=1
             ;;
             #(
              *  ) image_suffix=${2}
                   shift_cnt=2
             ;;
             esac
 ;;
 #(
 #*%OS%* ) exit 0
 #;;
 #(
   *    ) echo "Command ${@} not allowed or is (yet) not implemented" 1>&2
          exit 2
 ;;
 esac

      shift ${shift_cnt:-0}

      pod_suffix_name=
      while [ "${*}" != '' ]
      do
           case ${1} in
           #(
               -*|--* ) case "${1}" in
                        #(
                          *=* ) OPTION="${1}"
                        ;;
                        #(
                           * ) OPTION="${1}=${2}"
                               shift
                        ;;
                        esac
                        XPRA_OPTIONS="${XPRA_OPTIONS:+${XPRA_OPTIONS} ${OPTION}}"
                        XPRA_OPTIONS="${XPRA_OPTIONS:-${OPTION}}"
           ;;
           #(
               *      ) image_suffix=${image_suffix:-${1}}
                        shift
           ;;
           esac
      shift
      done
#
XPRA_OPTIONS="-e xpra_options='`echo ${XPRA_OPTIONS} | sed -e 's/ /${SP}/g'`'"
get_session_or_start
activate_ssh_proxy 
#exec echo ++${*}--${xsession}--${image_suffix}--${XPRA_OPTIONS}++ 1>2
