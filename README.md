### This is ANSOS-NG !

This bunch of scripts and ks files are used to create a livecd image (stateless) for archipel. It's based on oVirt node work without all the oVirt things...

### Why you don't use ovirt node anymore

Because ovirt node isn't really handy to configure for Archipel and because their lack of OpenVswitch support. Now building an ISO image is simplier as we don't rely on oVirt Node building processes.

### Requirements

```bash
yum install install wget livecd-tools appliance-tools-minimizer fedora-packager python-devel rpm-build createrepo selinux-policy-doc checkpolicy selinux-policy-devel autoconf automake python-mock python-lockfile git
```

If you want to build ovs, you need to add

yum install gcc make openssl-devel kernel-devel graphviz kernel-debug-devel automake redhat-rpm-config libtool git

For centos7 you can find the livecd-tools here: http://people.centos.org/arrfab/CentOS7/LiveMedia/RPMS/

### How to use

Install a build machine (you can use vagrant):

`vagrant init "vStone/centos-7.x-puppet.3.x" && vagrant up`

Add epel:

```bash
yum install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
```

Install all required dependencies:

For centos7 you need to install livecd-tools from (not yet in EPEL repo):

```
yum install http://people.centos.org/arrfab/CentOS7/LiveMedia/RPMS/livecd-tools-20.1-3.el7.x86_64.rpm http://people.centos.org/arrfab/CentOS7/LiveMedia/RPMS/python-imgcreate-20.1-3.el7.x86_64.rpm http://people.centos.org/arrfab/CentOS7/LiveMedia/RPMS/hfsplus-tools-540.1.linux3-4.el7.x86_64.rpm
```

and appliance-tools-minimizer from epel6:

```
yum install http://dl.fedoraproject.org/pub/epel/6/i386/appliance-tools-minimizer-007.7-2.1.el6.noarch.rpm
```

Install missing dependencies:

```bash
yum install install wget livecd-tools appliance-tools-minimizer fedora-packager python-devel rpm-build createrepo selinux-policy-doc checkpolicy selinux-policy-devel autoconf automake python-mock python-lockfile
```

Enable selinux:

Edit `/etc/sysconfig/selinux`, set it to enforcing and reboot.

And finally run:

```bash
wget https://raw.githubusercontent.com/CyrilPeponnet/ANSOS-NG/master/docker/buildANSOS.py
python buildANSOS.py -Bc -e https://repos.fedorapeople.org/repos/openstack/openstack-juno/epel-7/ -p openvswitch
```

This will build ANSOS-NG iso image based on Archipel git master and openVswitch from RDO repositories.

You can customize a lot of things just check with `python buildANSOS.py -h`.

### Docker build - beta
An attempt to use docker in order to build images can be found in docker folder. For now it doesn't work due to:
 * no selinux enforcing in docker containers
 * issue with /dev/mapper when resizing the iso image

Check the REAME.docker file for more information

### Kernel boot parameters

 * You can set kernel options used by dracut (see dracut boot options) in order to define your ip/hostname | other
 * You can use the built-in node-config daemon to do it in an old way: `use_node_config BOOTIF=[MAC|ifname] ip=[IP|dhcp] netmask=IP dns=IP gw=IP`
 * If you want to disable ssh Password Authentication (only use keys) you can add `no_ssh_pwauth` too.

### Post boot configuration

Please check https://github.com/ArchipelProject/Archipel/wiki/ANSOS:-Archipel-Node-Stateless-OS and adapt to ANSOS-NG

### Notes

If livecd-creator complain about unresolved depencies for /bin/python, just change the order of /usr/bin in PATH env var to be before /bin. (centos7)
