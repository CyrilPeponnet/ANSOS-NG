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

cat > /etc/rc.d/init.d/livesys << EOF
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
        ssh_pwauth=*)
            ssh_pwauth=\${i#ssh_pwauth=}
            ;;
    esac
done

[ ! -n "\$hostname" ] && hostname="archipel.node.local"

# set hostname

hostname "\$hostname"

# add static hostname to work around xauth bug
echo "\$hostname" > /etc/hostname

# retrieve the network interface from mac
if [ -n "\$BOOTIF" ]; then
	nif=\`ip -o l | grep -i \$BOOTIF | cut -d":" -f2\`
else
	# find the first device we found in biodevname
	nif=\`/sbin/biosdevname -d | awk 'FNR == 2 {print \$3}'\`
fi

# set hostname in /etc/hosts if ip exist and <> dhcp
if [ -n "\$ip" ] && [ "\$ip" != "dhcp"]; then
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

ifup \$nif

# enable or disable ssh pwauth (default is enable)
if [ -n "\$ssh_pwauth" ] && [ "\$ssh_pwauth" == "no"]; then
sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config 
systemctl restart sshd
fi

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

EOF


chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys

# enable tmpfs for /tmp
systemctl enable tmp.mount


# save a little bit of space at least...
rm -f /boot/initramfs*
# make sure there aren't core files lying around
rm -f /core*

