#!/bin/bash
#
ACTION=`basename ${0} | sed -e 's/\(^.\)\(.*$\)/\1/'`
NAMESPACE="${NAMESPACE:-vdi-ka}"
export ACTION NAMESPACE
#
        case ${ACTION} in
        #(
         S|s )
              :
        ;;
        #(
        K|k )
	   if [ -f "${XPRA_TOPDIR_INT}/etc/xpra-vars.sh" ]
           then
	     . "${XPRA_TOPDIR_INT}/etc/xpra-vars.sh"
	     if [ "${XPRA_STATUS_DIR}" != '' -a \
		  "${DNAME}" != '' -a -f "${XPRA_STATUS_DIR}/${DNAME}-xpra.rdy" ]
             then
		 rm -rf "${XPRA_STATUS_DIR}/${DNAME}-xpra.rdy"
             fi
           fi
        ;;
	esac
