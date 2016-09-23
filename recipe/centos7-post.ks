# remove errors from /sbin/dhclient-script
DHSCRIPT=/sbin/dhclient-script
sed -i 's/mv /cp -p /g'  $DHSCRIPT
sed -i '/rm -f.*${interface}/d' $DHSCRIPT
sed -i '/rm -f \/etc\/localtime/d' $DHSCRIPT
sed -i '/rm -f \/etc\/ntp.conf/d' $DHSCRIPT
sed -i '/rm -f \/etc\/yp.conf/d' $DHSCRIPT

# Hack to make python-sqlalchemy0.7 working on centos. seriously this sucks
# mv /usr/lib64/python2.6/site-packages/SQLAlchemy-*-py*-linux-$(uname -m).egg/sqlalchemy /usr/lib64/python2.6/site-packages/



# FIXME: it'd be better to get this installed from a package

cat > /etc/rc.d/init.d/node-config << EOF
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
# description: Init script for live image.
### BEGIN INIT INFO
# X-Start-Before: NetworkManager
### END INIT INFO

. /etc/init.d/functions

# parsing the args passed to the kernel

for i in \`cat /proc/cmdline\`; do
    case \$i in
        ip=*)
            ip=\${i#ip=}
            ;;
        netmask=*)
            netmask=\${i#netmask=}
            ;;
        gateway=*)
            gateway=\${i#gateway=}
            ;;
        dns=*)
            dns=\${i#dns=}
            ;;
        hostname=*)
            hostname=\${i#hostname=}
            ;;
        BOOTIF=*)
            BOOTIF=\${i#BOOTIF=}
            ;;
        no_ssh_pwauth)
            no_ssh_pwauth="True"
            ;;
        use_node_config)
			use_node_config="True"
			;;
    esac
done


# Make sure we don't mangle the hardware clock on shutdown
ln -sf /dev/null /etc/systemd/system/hwclock-save.service

# turn off firstboot for livecd boots
systemctl --no-reload disable firstboot-text.service 2> /dev/null || :
systemctl --no-reload disable firstboot-graphical.service 2> /dev/null || :
systemctl stop firstboot-text.service 2> /dev/null || :
systemctl stop firstboot-graphical.service 2> /dev/null || :

# don't use prelink on a running live image
sed -i 's/PRELINKING=yes/PRELINKING=no/' /etc/sysconfig/prelink &>/dev/null || :

# turn off mdmonitor by default
systemctl --no-reload disable mdmonitor.service 2> /dev/null || :
systemctl --no-reload disable mdmonitor-takeover.service 2> /dev/null || :
systemctl stop mdmonitor.service 2> /dev/null || :
systemctl stop mdmonitor-takeover.service 2> /dev/null || :


# don't start cron/at as they tend to spawn things which are
# disk intensive that are painful on a live image
systemctl --no-reload disable crond.service 2> /dev/null || :
systemctl --no-reload disable atd.service 2> /dev/null || :
systemctl stop crond.service 2> /dev/null || :
systemctl stop atd.service 2> /dev/null || :

# bind mount logs dir for common services to tmp
mkdir -p /tmp/var/log/{glusterfs,openvswitch,libvirtd}
mount -B /tmp/var/log/glusterfs /var/log/glusterfs
mount -B /tmp/var/log/openvswitch /var/log/openvswitch
mount -B /tmp/var/log/libvirt /var/log/libvirt

if [ -n "\$use_node_config" ]; then

[ ! -n "\$hostname" ] && hostname="archipel.node.local"

# set hostname
hostname "\$hostname"

# add static hostname to work around xauth bug
echo "\$hostname" > /etc/hostname

# retrieve the network interface from mac
if [ -n "\$BOOTIF" ]; then
	nif=\`ip -o l | grep -i \$BOOTIF | cut -d":" -f2 | tr -d " "\`
else
	# find the first device we found in biodevname
	nif=\`/sbin/biosdevname -d | awk 'FNR == 2 {print \$3}' | tr -d " "\`
fi

# set hostname in /etc/hosts if ip exist and <> dhcp
if [ -n "\$ip" ] && [ "\$ip" != "dhcp" ]; then
	if ! grep \$hostname /etc/hosts ; then
	    echo "\$ip \$hostname \`hostname -s\`" >> /etc/hosts
	fi
	# configure network
cat > /etc/sysconfig/network-scripts/ifcfg-\$nif << EFO
DEVICE=\$nif
BOOTPROTO=None
DNS1=\$dns
GATEWAY=\$gateway
IPADDR=\$ip
NETMASK=\$netmask
ONBOOT=yes
NM_CONTROLLED=yes
EFO
else
cat > /etc/sysconfig/network-scripts/ifcfg-\$nif << EFO
DEVICE=\$nif
BOOTPROTO=dhcp
ONBOOT=yes
NM_CONTROLLED=yes
EFO
fi

ifdown \$nif
ifup \$nif

fi

# enable or disable ssh pwauth (default is enable)
if [ -n "\$no_ssh_pwauth" ]; then
sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd
fi

EOF

# enable nested virt
echo "options kvm-intel nested=1" > /etc/modprobe.d/kvm-intel.conf
echo "options kvm-amd nested=1" > /etc/modprobe.d/kvm-amd.conf

chmod 755 /etc/rc.d/init.d/node-config
/sbin/restorecon /etc/rc.d/init.d/node-config
/sbin/chkconfig --add node-config

# enable tmpfs for /tmp
systemctl enable tmp.mount

# relocating logs to tmpfs
sed -i "s#/var#/tmp/var#g" /etc/audit/auditd.conf
sed -i "s#/var#/tmp/var#g" /etc/rsyslog.conf
sed -i "s#/var/log#/tmp/var/log#g" /etc/logrotate.d/syslog

# enable openvswitch
systemctl enable openvswitch

# save a little bit of space at least...
rm -f /boot/initramfs*
# make sure there aren't core files lying around
rm -f /core*
