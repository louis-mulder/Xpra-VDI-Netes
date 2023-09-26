
#!/bin/bash

# Startup xpra in proxy mode for ssl connections
#
# July-2023 Louis Mulder

PATH=${XPRA_TOPDIR_INT:-/srv}/bin:${PATH}
export PATH

exec xpra proxy :14500 --ssl-cert=/etc/xpra/cert.pem --ssl-key=/etc/xpra/key.pem \
                  --ssl-auth=pam:service=login --ssl=auto\
                  --ssl=auto\
                  --bind-ssl=0.0.0.0:14500 \
                  --proxy-start-sessions=no\
                  --html=on --daemon=no --mdns=no  
