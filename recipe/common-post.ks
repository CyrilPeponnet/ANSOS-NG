
# just to get a boot warning to shut up
touch /etc/resolv.conf

# make libvirtd listen on the external interfaces
sed -i -e 's/^#\(LIBVIRTD_ARGS="--listen"\).*/\1/' \
   /etc/sysconfig/libvirtd

# set up libvirtd to listen on TCP (for kerberos)
sed -i -e "s/^[[:space:]]*#[[:space:]]*\(listen_tcp\)\>.*/\1 = 1/" \
   -e "s/^[[:space:]]*#[[:space:]]*\(listen_tls\)\>.*/\1 = 0/" \
   /etc/libvirt/libvirtd.conf

# disable mdns/avahi
sed -i -e 's/^[[:space:]]*#[[:space:]]*\(mdns_adv = 0\).*/\1/' \
   /etc/libvirt/qemu.conf

# dracut config
cat <<_EOF_ > /etc/dracut.conf.d/archipel-node.conf

add_dracutmodules+="dmsquash-live"

_EOF_

# systemd configuration
# set default runlevel to multi-user(3)

rm -rf /etc/systemd/system/default.target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

echo "-w /etc/shadow -p wa" >> /etc/audit/audit.rules

