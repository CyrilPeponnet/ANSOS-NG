# remove
-fedora-release
-fedora-release-notes
-fedora-logos
generic-logos


# keyboard layout
system-config-keyboard-base
# plymouth stuff
plymouth
plymouth-system-theme
plymouth-plugin-label
plymouth-graphics-libs
plymouth-scripts
plymouth-plugin-two-step
plymouth-theme-charge

# f18 doesn't pull in rsyslog
rsyslog

kbd-misc

#async reboot
python-daemon

grub2-efi
firewalld
selinux-policy-devel
shim
# qlogic firmware
linux-firmware
iptables
net-tools
vconfig
bfa-firmware
grubby

# Explicitly add these package, to prevent yum from pulling in the debug versions
kernel-modules-extra

# To disable hostonly mode
dracut-config-generic
