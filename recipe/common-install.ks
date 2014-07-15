lang en_US.UTF-8
keyboard us
timezone US/Pacific
auth --useshadow --enablemd5
selinux --enforcing
firewall --disabled

part / --fstype ext4 --size 5124

network --bootproto=dhcp