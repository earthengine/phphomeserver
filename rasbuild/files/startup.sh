#!/bin/bash
if [ ! -z $1 ]; then
	echo "%wheel ALL=(ALL) ALL" >> $1
else
	export EDITOR="./$0"
	visudo
	locale-gen
	netctl start ethernet-dhcp
	netctl enable ethernet-dhcp
	systemctl enable openntpd sshd lighttpd
	parted /dev/mmcblk0 --script mkpart primary ext4 1878MB $(parted /dev/mmcblk0 --script print | grep '^Disk' | cut -d ' ' -f 3)
	groupadd -g 439 ldap &>/dev/null
	useradd -u 439 -g ldap -d /var/lib/openldap -s /bin/false ldap &>/dev/null
	rm /root/startup.sh
	reboot
fi
