#!/bin/bash
#
#
# Startup xpra desktop/seamless session in container/pod
# Or seamless session depends on the hostname
#
# Louis Mulder 
#
SRC_PORT=${SRC_PORT:-14500}

XPRA_OPTIONS="${XPRA_OPTION:-${1}}"
SP=' ' ; export SP
if [ "${XPRA_OPTIONS}" != '' ]
then
   XPRA_START_OPTIONS=` set -- \` eval echo ${XPRA_OPTIONS} \`
                        LIST=''
                        while [ "${1}" != '' ]
                        do
			  case ${1} in 
		          #(
			    --* ) case ${1} in
			          #(
				  *=* ) 
			               LIST=${LIST:+${LIST} ${1}}
			               LIST=${LIST:-${1}}
				  ;;
				  #(
				  *   )
			               LIST=${LIST:+${LIST} ${1}}
			               LIST=${LIST:-${ARG}${1}}
				       shift
			               LIST=${LIST:+${LIST} ${1}}
				  ;;
		                  esac
                          ;;
	                  esac
			  shift
			done
			echo ${LIST} `
fi
export XPRA_START_OPTIONS
# #permissions and group ownership of /run/xpra
# XPRA_SOCKET_DIR_GROUP=xpra
# groupadd ${XPRA_SOCKET_DIR_GROUP}
#

export U_USER
#

TCP_AUTH='pam:service=login'

LOCALE_GEN=`which locale-gen`
[ "${LOCALE_GEN}" != '' ] && ${LOCALE_GEN} en_US.UTF-8 &

XDG_RUNTIME_DIR=/tmp/${U_UID} ; export XDG_RUNTIME_DIR

mkdir -p ${XDG_RUNTIME_DIR}/xpra/0
chown -R ${U_UID}:${U_GID} ${XDG_RUNTIME_DIR}
#
HOSTNAME=`hostname`
#
XSESSION=`echo ${HOSTNAME} | sed -e 's/'"${U_USER}"'-//' `
PROXY_START=start
case ${XSESSION} in
#(
  *desktop* ) PROXY_START='start-desktop'
;;
esac


#
   SOCAT=`command -v socat`

   if [ "${SOCAT}" != '' -a -x "${SOCAT}" ]
   then
     mkdir -p /run/xpra/u-socket 2> /dev/null
     CMD="${SOCAT} UNIX-LISTEN:/run/xpra/u-socket/command-lock,fork EXEC:bash"
     chown ${U_UID}:${U_GID} /run/xpra/u-socket
   else
     CMD=/bin/true
   fi
   
   cd /etc/xpra
   chown ${U_UID}:${U_GID} *.pem
   chmod 400 cert.pem
   chmod 400 key.pem
   SSL_CERT=/etc/xpra/cert.pem
   SSL_KEY=/etc/xpra/key.pem

   cd ${U_HOME}

   xpra ${PROXY_START}  :0\
                                            --html=on  \
		                            --uid=${U_UID}\
					    --gid=${U_GID}\
					    --systemd-run=no\
					    --file-transfer=no\
					    --clipboard=no\
					    --clipboard-direction=disabled\
					    --daemon=no\
					    --mdns=yes\
					    --bind-ssl=0.0.0.0:${SRC_PORT:-14500} \
					    --bind-wss=0.0.0.0:`expr ${SRC_PORT:-14500} + 43`\
                                            --wss-auth=${TCP_AUTH} \
					    --ssl-auth=${TCP_AUTH} \
					    --bind-tcp=localhost:14080 \
					    --ssl-cert=${SSL_CERT}\
				            --ssl-key=${SSL_KEY}\
					    --pidfile=/run/user/${U_UID}/xpra-${HOSTNAME}-pid\
                                            --pulseaudio=yes \
                                            --pulseaudio-command=start-pulseaudio-x11 \
					    --ssl=auto\
                                            --speaker=on\
					    --webcam=no\
					    --start-new-commands=yes\
					    --resize-display=1600x900\
					    --env=LC_ALL=en_US.UTF-8 \
                                            --start="${CMD}" \
					    ${XPRA_START_OPTIONS} 1>&2
#
#

#
# if you want to debug
#

#sleep 36000
