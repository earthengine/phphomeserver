HOME=$(pwd)
echo $HOME
ROOT=/root/archroot
FILES=$HOME/files
echo $ROOT
PACKAGES="linux-raspberrypi linux-firmware raspberrypi-firmware less iputils procps-ng"
#PACKAGES="$PACKAGES systemd-sysvcompat"
PACKAGES="$PACKAGES man man-db grep dialog psmisc which sudo dhcpcd ifplugd net-tools netctl"
PACKAGES="$PACKAGES openntpd openssh bind samba nano openldap aria2 parted"
PACKAGES="$PACKAGES lighttpd ssmtp fcgi php php-cgi sqlite imagemagick "
#PACKAGES="$PACKAGES binutils bison cloog fakeroot file flex gcc gettext git "
#PACKAGES="$PACKAGES autoconf automake linux-headers-raspberrypi pkg-config tar patch"
#PACKAGES="$PACKAGES pacman pacman-mirrorlist"
CACHE=$HOME/pacman_cache
DB=$HOME/pacman_db

function doInstall(){
DB_TEMP=$(mktemp -d)
echo $DB_TEMP
sed -e "s@/etc/pacman.d/mirrorlist@$FILES/mirrorlist@g" $FILES/pacman.conf > $DB_TEMP/pacman.conf
CONF=$DB_TEMP/pacman.conf
PACMAN_BASE="pacman --root $ROOT --cachedir $CACHE --config $CONF"
PACMAN="$PACMAN_BASE --dbpath=$DB_TEMP"
$PACMAN_BASE --dbpath=$DB -Sy || return 0
cp -R $DB/* $DB_TEMP/ || return 0
$PACMAN -S filesystem licenses gcc-libs || return 0
$PACMAN -S $PACKAGES || return 0
$PACMAN -U /home/joe/php-imagick-3.0.1-4-armv6h.pkg.tar.xz || return 0

#mv $ROOT/etc/fstab{,-}
#echo "/dev/sda2 / ext4	defaults	0	0" >> $ROOT/etc/fstab
cp -v {$FILES,$ROOT}/boot/cmdline.txt
cp -v {$FILES,$ROOT}/boot/config.txt
echo '/dev/mmcblk0p1  /boot           vfat    defaults        0       0' >> $ROOT/etc/fstab
cp -v {$FILES,$ROOT}/etc/passwd
chmod 644 $ROOT/etc/passwd
cp -v {$FILES,$ROOT}/etc/group
chmod 644 $ROOT/etc/group
cp -v {$FILES,$ROOT}/etc/locale.conf
chmod 644 $ROOT/etc/locale.conf
cp -v {$FILES,$ROOT}/etc/locale.gen
chmod 644 $ROOT/etc/locale.gen
cp -v {$FILES,$ROOT}/etc/shadow
chmod 640 $ROOT/etc/shadow
#cp -v $ROOT/etc/netctl/{examples/,}ethernet-dhcp
cp -v {$FILES,$ROOT}/etc/netctl/ethernet-static
cp -v $FILES/etc/ssh/* $ROOT/etc/ssh
cp -v {$FILES,$ROOT/root}/startup.sh
cp -v {$FILES,$ROOT}/etc/systemd/system/initialsetup.service
chmod +x $ROOT/root/startup.sh
install -d $ROOT/home/joe

echo "raspserver" > $ROOT/etc/hostname
echo "include /etc/lo.so.conf.d/*.conf" >> $ROOT/etc/lo.so.conf
$PACMAN -Q > $HOME/targetlist
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

