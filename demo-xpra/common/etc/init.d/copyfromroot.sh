#!/bin/bash

if [ -d ${XPRA_TOPDIR_INT:-/srv}/os-root/. ]
then
   cd ${XPRA_TOPDIR_INT:-/srv}/os-root
   exec 2> /dev/null
   tar cf - . | (cd / ; tar xf -)
fi
