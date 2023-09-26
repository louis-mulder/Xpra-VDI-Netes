exit 0
#
# Perform default/personal/group iptables settings
#
   if cd  ${XPRA_TOPDIR_INT}/etc/iptables/.
    then
    if cd default
    then
        for exe in ip*.sh
        do
          [ -x ${exe} ] && ./${exe}
        done
    cd ..
    fi

    if cd users
    then
      if cd ${USER:-dummy} 2> /dev/null
      then
          for exe in ip*.sh
          do
            [ -x ${exe} ] && ./${exe}
          done
      cd ..
      fi
    cd ..
    fi
    if cd groups
    then
     for dir in `groups ${USER:-dummy} 2> /dev/null  | sed -e 's/'"${USER}"'//g' \
                                              -e 's/://g'`
     do
       if cd ${dir} 2> /dev/null
       then
        for exe in ip*.sh
        do
         [ -x ${exe} ] && ./${exe}
        done
       cd ..
      fi
     cd ..
     done
    cd ..
    fi
   fi

#
##
##
#
     iptables -F INPUT
     iptables -A INPUT -i lo -j ACCEPT
     iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
     iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
     iptables -A INPUT -j REJECT

