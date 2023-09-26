#!/bin/bash

get-free() {
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
) |python3
}
echo "Unused Port: `get-free`"
