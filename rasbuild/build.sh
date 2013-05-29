if [ "$1" == "" ]; then
	echo "Usage: /bin/bash build.sh <target IP from 139-254>"
	exit 1
fi
HOME=$(pwd)
IP=$1
echo $HOME
ROOT=/root/archroot
FILES=$HOME/files
echo $ROOT
PACKAGES="linux-raspberrypi linux-firmware raspberrypi-firmware less iputils procps-ng"
PACKAGES="$PACKAGES man grep dialog libsigsegv psmisc which sudo dhcpcd ifplugd net-tools netctl"
PACKAGES="$PACKAGES openntpd openssh bind samba nano openldap aria2 parted"
PACKAGES="$PACKAGES lighttpd ssmtp fcgi php php-cgi sqlite imagemagick "
PACKAGES="$PACKAGES binutils bison cloog fakeroot file flex gcc gettext git "
PACKAGES="$PACKAGES autoconf automake linux-headers-raspberrypi pkg-config tar patch"
PACKAGES="$PACKAGES pacman pacman-mirrorlist"
CACHE=$HOME/pacman_cache
DB=$HOME/pacman_db

function doInstall(){
sed -e "s@/etc/pacman.d/mirrorlist@$FILES/mirrorlist@g" $FILES/pacman.conf > $ROOT/pacman.conf
CONF=$ROOT/pacman.conf
PACMAN_BASE="pacman --root $ROOT --cachedir $CACHE --config $CONF"
PACMAN=$PACMAN_BASE
DB_TEMP=$ROOT/var/lib/pacman
install -d $ROOT/var/lib/pacman
install -d $ROOT/var/cache/pacman/pkg
$PACMAN_BASE --dbpath=$DB -Sy || return 0
cp -R $DB/* $DB_TEMP/ || return 0
#DB_TEMP=$(mktemp -d)
#echo $DB_TEMP
#sed -e "s@/etc/pacman.d/mirrorlist@$FILES/mirrorlist@g" $FILES/pacman.conf > $DB_TEMP/pacman.conf
#CONF=$DB_TEMP/pacman.conf
#PACMAN="$PACMAN_BASE --dbpath=$DB_TEMP"
#$PACMAN_BASE --dbpath=$DB -Sy || return 0
#cp -R $DB/* $DB_TEMP/ || return 0
$PACMAN -S licenses man-db systemd || return 0
$PACMAN -S $PACKAGES || return 0
$PACMAN -U /home/joe/php-imagick-3.0.1-4-armv6h.pkg.tar.xz || return 0

install -v {$FILES,$ROOT}/boot/cmdline.txt
install -v {$FILES,$ROOT}/boot/config.txt
install -v --mode=644 {$FILES,$ROOT}/etc/passwd
install -v --mode=644 {$FILES,$ROOT}/etc/group
install -v --mode=644 {$FILES,$ROOT}/etc/locale.conf
install -v --mode=644 {$FILES,$ROOT}/etc/locale.gen
install -v --mode=640 {$FILES,$ROOT}/etc/shadow
install -v --mode=644 {$FILES,$ROOT}/etc/netctl/ethernet-static
install -v --mode=640 {$FILES,$ROOT}/etc/openldap/slapd.conf
sed -i "s/10.0.0.139/10.0.0.${IP}/g" $ROOT/etc/netctl/ethernet-static
cp -v $FILES/etc/ssh/* $ROOT/etc/ssh
cp -v {$FILES,$ROOT/root}/startup.sh
install -v --mode=744 {$FILES,$ROOT}/etc/systemd/system/initialsetup.service
install -dv {$FILES,$ROOT}/etc/systemd/system/basic.target.wants
ln -sv $ROOT/etc/systemd/system/{initialsetup.service,basic.target.wants/}
install -d -o 1000 $ROOT/home/joe

echo "raspserver" > $ROOT/etc/hostname
echo "include /etc/lo.so.conf.d/*.conf" >> $ROOT/etc/lo.so.conf
$PACMAN -Q > $HOME/targetlist
rm $ROOT/pacman.conf
chown joe $HOME/targetlist
}

losetup /dev/loop0 /remote/phphomeserver/rasbuild/archlinuxarm.img
kpartx -v -a /dev/loop0
mkfs.vfat /dev/mapper/loop0p1
mkfs.ext4 /dev/mapper/loop0p2
install -d $ROOT
mount /dev/mapper/loop0p2 $ROOT
install -d $ROOT/boot
mount /dev/mapper/loop0p1 $ROOT/boot
install -d $ROOT/dev
mount --bind /dev $ROOT/dev

doInstall

umount $ROOT/dev
umount /dev/mapper/loop0p1
umount /dev/mapper/loop0p2
kpartx -d /dev/loop0
losetup -d /dev/loop0

