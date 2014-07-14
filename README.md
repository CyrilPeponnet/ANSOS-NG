### This is ANSOS-NG !

This bunch of scripts and ks files are used to create a livecd image (stateless) for archipel. It's based on oVirt node work without all the oVirt things...

### Why you don't use ovirt node anymore

Because ovirt node isn't really handy to configure for Archipel and because their lack of OpenVswitch support. Now building an ISO image is simplier as we don't rely on oVirt Node building processes.

### Requirements
yum install install livecd-tools appliance-tools-minimizer fedora-packager python-devel rpm-build createrepo selinux-policy-doc checkpolicy selinux-policy-devel autoconf automake python-mock python-lockfile

### Docker build
An attempt to use docker in order to build images can be found in docker folder. For now it doesn't work due to:
 - no selinux enforcing in docker containers
 - issue with /dev/mapper when resizing the iso image
