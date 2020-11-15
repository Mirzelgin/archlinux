= Arch Linux step-by-step installation =
= http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html =


== Boot the installation CD ==

loadkeys ru
setfont cyr-sun16

== Create partition ==

cfdisk -z /dev/sda

== Format the partition ==

mkfs.btrfs -L "Arch Linux" /dev/sda1

== Mount the partition ==

mkdir /mnt/btrfs-root
mount -o defaults,relatime,discard,ssd,nodev,nosuid /dev/sda1 /mnt/btrfs-root

== Create the subvolumes ==

mkdir -p /mnt/btrfs/__snapshot
mkdir -p /mnt/btrfs/__current
btrfs subvolume create /mnt/btrfs-root/__current/root
btrfs subvolume create /mnt/btrfs-root/__current/home

== Mount the subvolumes ==

mkdir -p /mnt/btrfs-current

mount -o defaults,relatime,discard,ssd,nodev,subvol=__current/root /dev/sda1 /mnt/btrfs-current
mkdir -p /mnt/btrfs-current/home

mount -o defaults,relatime,discard,ssd,nodev,nosuid,subvol=__current/home /dev/sda1 /mnt/btrfs-current/home

== Install Arch Linux ==

pacstrap /mnt/btrfs-current base base-devel
genfstab -U /mnt/btrfs-current >> /mnt/btrfs-current/etc/fstab
nano /mnt/btrfs-current/etc/fstab

== Configure the system ==
 
arch-chroot /mnt/btrfs-current /bin/bash

pacman -S btrfs-progs

sed -i "s/#\(en_US\.UTF-8\)/\1/" /etc/locale.gen
sed -i "s/#\(ru_RU\.UTF-8\)/\1/" /etc/locale.gen

locale-gen

echo LANG=ru_RU.UTF-8 > /etc/locale.conf
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

echo 'idv-HP-EliteBook-840-G1' > /etc/hostname

pacman -S wicd
systemctl enable wicd.service

nano /etc/mkinitcpio.conf
mkinitcpio -p linux

passwd

== Install boot loader ==

pacman -S grub-bios
grub-install --target=i386-pc --recheck /dev/sda
nano /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

== Unmount and reboot ==

exit

umount /mnt/btrfs-current/home
umount /mnt/btrfs-current
umount /mnt/btrfs-root

reboot

== Post installation configuration ==

=== Snapshot ===

echo `date "+%Y%m%d-%H%M%S"` > /run/btrfs-root/__current/ROOT/SNAPSHOT
echo "Fresh install" >> /run/btrfs-root/__current/ROOT/SNAPSHOT
btrfs subvolume snapshot -r /run/btrfs-root/__current/ROOT /run/btrfs-root/__snapshot/ROOT@`head -n 1 /run/btrfs-root/__current/ROOT/SNAPSHOT`
cd /run/btrfs-root/__snapshot/
ln -s ROOT@`cat /run/btrfs-root/__current/ROOT/SNAPSHOT` fresh-install
rm /run/btrfs-root/__current/ROOT/SNAPSHOT 

==== Software Installation ===
visudo
