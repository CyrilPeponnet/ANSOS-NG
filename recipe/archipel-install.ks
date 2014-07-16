## bootloader
bootloader --timeout=30 --append="rd_NO_MULTIPATH rootflags=ro crashkernel=128M elevator=deadline install quiet max_loop=256 stateless=1"

# Root password 'archipel' by default - you should change to a real password (use "grub-md5-crypt" to get the crypted version)
rootpw --iscrypted $1$zVbXo1$DK/.wyZxQ3NnBWYgoKhJt/