#!/bin/bash

# Скрипт установки Arch Linux efi
dev="/dev/sda"

# Устанавливаем русскую раскладку клавиатуры (на сессию)
loadkeys ru

# Устанавливаем шрифты с поддержкой кирилицы (на сессию)
setfont cyr-sun16

# Синхронизируем часы
timedatectl set-ntp true

# Устанавливаем утилиты для работы с btrfs
pacman -Sy btrfs-progs

# Разметка диска (-z обнуление таблицы разделов)
cfdisk -z $dev

## efi раздел
mkfs.fat -F32 -f $dev'1'

## swap раздел
mkswap $dev'2'
swapon $dev'2'

## root раздел
mkfs.btrfs -f $dev'3'

# Монтируем раздел
mount $dev'3' /mnt

# Создаём два подтома под корень и домашние каталоги
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@snapshots

# Отмонтируем корень ФС
umount /mnt

# Монтируем корневой раздел (c включенным TRIM)
mount -o noatime,compress=zstd,subvol=@ discard=async $dev'3' /mnt

# Создаём директории home, var, .snapshots и монтируем соответствуюущие subvolume
mkdir -p /mnt/{boot,home,var,.snapshots}
mount $dev'1' /mnt/boot
mount -o noatime,compress=zstd,subvol=@home discard=async $dev'3' /mnt/home
mount -o noatime,compress=zstd,subvol=@var discard=async $dev'3' /mnt/var
mount -o noatime,compress=zstd,subvol=@snapshots discard=async $dev'3' /mnt/.snapshots

# Обновляем зеркала
## Создаём резервную копию списка зеркал
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

## Устанавливаем пакет reflector для обновления зеркал
pacman -Sy reflector

## Запускаем reflector
reflector --verbose  -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist

## Обновляем пакеты
pacman -Syyu

# Установка системы
pacstrap /mnt base base-devel linux linux-firmware linux-headers btrfs-progs grub grub-btrfs efibootmgr vim networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools reflector

# Генерируем fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt /bin/bash

# Имя компьютера
echo "arch-mir" > /etc/hostname

# Настройка часового пояса
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Локализация
## Устанавливаем английскую и русскую локали
sed -i "s/#\(en_US\.UTF-8\)/\1/" /etc/locale.gen
sed -i "s/#\(ru_RU\.UTF-8\)/\1/" /etc/locale.gen

## Обновляем текущую локаль
locale-gen

## Устанавливаем русский язык системы
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

## Устанавливаем keymap и шрифт для консоли
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

# Пароль root
passwd

# Установка загрузчика
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Включаем NetworkManager
systemctl enable NetworkManager
