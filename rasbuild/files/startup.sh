#!/bin/bash
if [ ! -z $1 ]; then
	echo "%wheel ALL=(ALL) ALL" >> $1
else
	export EDITOR="./$0"
	visudo
	locale-gen
	timedatectl set-timezone Australia/Melbourne
	netctl enable ethernet-static
	sed -e 's/MYGROUP/WORKGROUP/g' /etc/samba/smb.conf.default > /etc/samba/smb.conf
	systemctl enable openntpd sshd lighttpd
	systemctl disable initialsetup.service
	parted /dev/mmcblk0 --script mkpart primary ext4 1878MB $(parted /dev/mmcblk0 --script print | grep '^Disk' | cut -d ' ' -f 3)
	mkfs.ext4 /dev/mmcblk0p3
	mount /dev/mmcblk0p3 /mnt
	mkdir /mnt/ftp
	mkdir /mnt/http
	chgrp ftp /mnt/ftp
	umount /mnt
	sync
	mkdir /router
	echo "/dev/mmcblk0p3 /srv ext4 defaults 0 0" >> /etc/fstab
	echo "//10.0.0.137/Disk_a1/Shared /router cifs defaults 0 0" >> /etc/fstab
	rm /root/startup.sh
	systemctl reboot
fi
