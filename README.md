### This is ANSOS-NG !

This bunch of scripts and ks files are used to create a livecd image (stateless) for archipel. It's based on oVirt node work without all the oVirt things...

### Why you don't use ovirt node anymore

Because ovirt node isn't really handy to configure for Archipel and because their lack of OpenVswitch support. Now building an ISO image is simplier as we don't rely on oVirt Node building processes.

### Requirements
yum install install livecd-tools appliance-tools-minimizer fedora-packager python-devel rpm-build createrepo selinux-policy-doc checkpolicy selinux-policy-devel autoconf automake python-mock python-lockfile

If you want to build ovs, you need to add

yum install gcc make openssl-devel kernel-devel graphviz kernel-debug-devel automake redhat-rpm-config libtool

For centos7 you can find the livecd-tools here: http://people.centos.org/arrfab/CentOS7/LiveMedia/RPMS/

### How to use

Install a build machine (you can use vagrant !), tested on centos6 and centos7, install all required dependencies, and run 

```bash
wget https://raw.githubusercontent.com/CyrilPeponnet/ANSOS-NG/master/docker/buildANSOS.py
python buildANSOS.py -Bc -o 2.1.2
```

This will build ANSOS-NG iso image based on Archipel git master and openVswitch 2.1.2. You can customize a lot of things just check with `python buildANSOS.py -h`

### Docker build - beta
An attempt to use docker in order to build images can be found in docker folder. For now it doesn't work due to:
 - no selinux enforcing in docker containers
 - issue with /dev/mapper when resizing the iso image

Check the REAME.md file for more information

### Notes

If livecd-creator complain about unresolved depencies for /bin/python, just change the order of /usr/bin in PATH env var to be before /bin. (centos7)

Centos7:
By default centos will not configure the network interfaces, you have two choices:
 * You can set kernel options used by dracut (see dracut boot options) in order to define your ip/hostname | other
 * You can use the built-in node-config daemon to do it in an old way: `use_node_config BOOTIF=[MAC|ifname] ip=[IP|dhcp] netmask=IP dns=IP gw=IP`

 If you want to disable ssh Password Authentication (only use keys) you can add `no_ssh_pwauth` too. 