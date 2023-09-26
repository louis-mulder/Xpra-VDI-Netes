
 VDI sessions with Xpra on a Kubernetes cluster

 The whole setup is based on NFS shared storage. All the images are
 based on Centos 8. To run the demo you need to untar the tarball
 on a exported filessystem.
 It will create a subdir demo-xpra. Under this directory the files
 will be placed. This setup is an example how to run Xpra without any
 modification in the source-code of Xpra. (xpra.org)

 Needed to run is a K8 cluster with or without Multus and Ldap environment. 
 This setup is done with a FreeIpa environment, used only the ldap functionality.
 Advantage is you can use 2-factor authentication. If a user is configured
 with 2FA the user must give on password question its password concatenated 
 with the OTP code. (freeotp on a smartphone etc.) Example:
 Password 'G0@w@y' code 324122 --> enter G0@w@y324122. 

 All the the pods can run multihomed if wanted. Therefore you will find a subdir
 multus to deploy a second network. Be aware on the used nodes a second NIC
 must be configured. This can be physical device or for example a Vlan. On the this 
 network a DHCP-server must be active. One yaml file is to deploy the
 Multus pods. The other contains the network attach definition and the 
 device of the underlaying node. Be sure the name is everywhere the same.
 For more information see: https://github.com/k8snetworkplumbingwg/multus-cni
 
 All the traffic between the pods is encrypted with SSH also accessing the
 proxy-server. Some security measures are done for example logging with ssh to
 underlaying nodes over the pod-network is closed with iptables.
 Via some scripting etc. inter-active using ssh with port 2222 on the service is 
 as much not possible. Scp/sftp is useless if it works files will be not delivered 
 where they will be expected. 
 Be free to improve.

 Accessing the service is set to port 2222 so from the client:

         Desktop session:
         xpra start-desktop ssh//<service ip>:2222 [ --start=xfce4-session ]
         Seamless session:
         xpra start ssh//<service ip>:2222 
         (BTW. Don't USE xfce4-session or similar, no window manager gives a lot of mesh)

          
 How to install briefly.

 Step 1:

 Build the images resides under .../demo-xpra/images. Under the subdirs
 you will find some doit scripts. Change the variable REGISTRY pointing
 to your registry server.
 Images will be build with buildah/podman. If not installed provide the 
 Linux setup with these container-tools. 

 Step 2: 

 If images are in the registry go to subdir yaml and adjust xpra-proxy-ssh.yaml
 with desired settings etc. Do the same in ../common/cms/ansible and deeper.
 You will find variables configured with contents pointing to synologyXX 
 and source-pathsof NFS. Also ldap settings etc,
 Under ansible you must adjust all the yaml-files under include, playbooks, etc.

 Step 3: 

 Create the namespace demo-xpra with kubectl create namespace demo-xpra
 and create the secret xpra-proxy-kube with 
  kubectl -n demo-xpra create secret xpra-proxy-kube --from-file=/root/.kube/config

 Step 4: 

 If you want to a second network so you can access the sessions directly with for example
 ssl/wss (port# 14500/14543) os ssh (port# 14222) install multus. How this works see the
 documentation. Go to the subdir multus and perform a kubectl apply -f multus-daemonset-thick.yml.
 Adjust the file xpra-dhcp-mdns.yml for the underlaying extra NIC on the nodes. Further you
 need a DHCP server on this second network, for example a Openwrt setup. Perform a
 kubectl apply -f xpra-dhcp-mdns.yml.

 If no multihomed pods edit the xpra-proxy-ssh.yaml (step 2) comment out the network definition.

 Step 5:

 If this done go to .../demo-xpra/yaml en run kubectl apply -f xpra-proxy-ssh.yaml.
 it will deploy a service and a pod xpra-proxy-XXXX.
 Be aware the some names of yaml-files are depending on the directory name of this setup.
 For example ..../demo-xpra/common/cms/ansible/playbooks/demo-xpra-client.yaml and under
 ..../includes/demo-xpra.yaml.  If the directory name my-name than you must rename 
 demo-xpra-client.yaml to my-name-client.yaml and also in includes
 to my-name.yaml.
 See also the content of .../demo-xpra/common/cms/ansible/playbooks/demo-xpra-client.yaml
 in the first lines.

 Step 6:

 Test  with a Xpra client 
 On the client search for the Python file client_base.py and change TIMEOUT_EXTRA=10 to the
 value 90. To startup a pod with Xpra will take more time. Especially the first time
 (downloading image), if it happens try a attach a few minutes
 later. Or use kubect -n demo-xpra get pod -o wide on the kubemaster to see what
 is happening.

 xpra start-desktop ssh://<service ip-address:2222> --start=xfce4-session and cross your fingers.

 Multihomed.

 If clients pods running multihomed and the network is routed to network where the clients
 are connected and the ip-address of the client is known the session also accessable with:

                 P.Q.R.S = ip-address
                 xpra attach wss://P.Q.R.S:14543 --ssl-server-verify-mode=none --ssl-ca-certs=<ssl-ca file>
                 or 
                 xpra attach ssl://P.Q.R.S:14500 --ssl-server-verify-mode=none --ssl-ca-certs=<ssl-ca file>
                 or
                 browser with URL: https://P.Q.R.S:14500
                 and
                 xpra attach ssh:P.Q.R.S:14222

 It is for the user/admin how to obtain the /etc/xpra/ssl-ca.pem from the session (xpra) pod/container. Scp/sftp 
 will not work because of security.

 Creating a session can be done only via ssh. For more protection a firewall can be used instead
 of router, only pass port 14500,14543 and 14222. If no ssh access is permitted block port 14222.

 In cases where more security is desired separate the ssh-proxy from the k8 cluster and shows
 only the ip-address of the created session. Shut port 14222 on a firewall and let users 
 only use port 14500 (wss,ssl and browser)

 General.

 Clipboard between the outside of client to inside session is switched of. Must be set on adjust 
 .../demo-xpra/x-session/xpra/xsession/xpra_startup_desktop.sh, this is hard-linked to seamless.

 For creating a pod (session) Ansible is used but it can be always replaced by another CMS or script
 but Ansible has nice k8 modules (definition).

 This setup is as it is and is only starting point to make your own implementation for a lot of use
 cases such as personal steppingstones, running X-based programs etc. With this tool you can place
 a whole development desktop behind a glasswall. In a lot of cases it can replace Citrix/Putty wherei
 used as administrate Linux/Unix servers.

 Hopefully this setup will inspire a lot of people. I am now a retired engineer with Unix background
 until 1979 so be free to use it as starting point. And how it is done study on the scripts.
 BTW. A similar setup can be also done for other container techniques or for example full virtuals machines.
      Also a pretty solution to put applications behind bars or stepping-stones with X11 support.
