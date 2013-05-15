#!/bin/bash
if [ ! -z \$1 ]; then
	echo "%wheel ALL=(ALL) ALL" >> \$1
else
	export EDITOR="./\$0"
	visudo
	locale-gen
	netctl start ethernet-dhcp
	netctl enable ethernet-dhcp
	systemctl enable openntpd sshd lighttpd
	rm /root/startup.sh
	reboot
fi
