audit
grubby
dmraid
bc
samba-client
cifs-utils
cracklib-python
ethtool
kernel
hwdata
passwd
policycoreutils
rootfiles
dhclient
openssh-clients
openssh-server
ntp
ntpdate
net-snmp
tuned
qemu-kvm
libmlx4
selinux-policy-targeted
vim-minimal
NetworkManager
NetworkManager-config-server
NetworkManager-glib
NetworkManager-libreswan
NetworkManager-tui
sudo
pm-utils
python
python-gudev
python-libs
python-setuptools
python-requests
python-argparse
PyPAM
#db4
# debugging
hdparm
sos
gdb
strace
sysstat
tcpdump
pciutils
usbutils
lsscsi
psmisc
numactl
file
lsof
newt-python
systemtap-runtime
qemu-kvm-tools
setools-console
# remove
-audit-libs-python
-ustr
-authconfig
-wireless-tools
-setserial
-prelink
-newt
-libselinux-python
-usermode
-gzip
-less
-which
-parted
-tar
-libuser
-mtools
-cpio
/usr/sbin/lokkit
isomd5sum
irqbalance
acpid
device-mapper-multipath
kpartx
dracut-network
dracut-fips
patch
e2fsprogs
sysfsutils
less
iotop
# Autotest support rhbz#631795
dosfstools
# kdump
kexec-tools

# dracut dmsquash-live module requires eject
eject

# for building custom selinux module
make
checkpolicy
#
policycoreutils-python
# crypto swap support
cryptsetup-luks
# rhbz#641494 RFE - add libguestfs
libguestfs
python-libguestfs
libguestfs-tools-c
python-hivex
# sosreport soft-dep
rpm-python
# for efi installs
efibootmgr
# yum for plugins
yum
# Consistent ethernet device naming
biosdevname
fcoe-utils

bridge-utils
squashfs-tools
mcelog

# for qemu
libicu
