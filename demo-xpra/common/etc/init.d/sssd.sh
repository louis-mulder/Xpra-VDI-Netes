#!/bin/bash
#
# Louis Mulder Aug. 2021
#
# Xpra is released under the terms of the GNU GPL v2, or, at your option, any
# later version. See the file COPYING for details.
#
#
if [  -f /etc/sssd/sssd.conf ] 
then
    ln /etc/sssd/sssd.conf /etc/sssd/--sssd.conf
    rm -rf /etc/sssd/sssd.conf*
    mv /etc/sssd/--sssd.conf /etc/sssd/sssd.conf 
    exec sssd -D --logger=files
fi
