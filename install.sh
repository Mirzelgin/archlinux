#!/bin/bash

# Скрипт установки Arch Linux efi

# Устанавливаем русскую раскладку клавиатуры (на сессию)
loadkeys ru

# Устанавливаем шрифты с поддержкой кирилицы (на сессию)
setfont cyr-sun16

# Синхронизируем часы
timedatectl set-ntp true

# Устанавливаем утилиты для работы с btrfs
#pacman -Sy btrfs-progs

# Разметка диска (-z обнуление таблицы разделов)
cfdisk -z /dev/sda

## Swap раздел
mkswap /dev/sda1

## root раздел
mkfs.btrfs -L "root" /dev/sda<цифра>

# Монтируем раздел
mount /dev/sda2 /mnt

# Создаём два подтома под корень и домашние каталоги
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

# Отмонтируем корень ФС
umount /mnt

# Монтируем корневой раздел (c включенным TRIM)
mount -o subvol=@,compress=zstd discard=async /dev/sda2 /mnt

# Создаём директорию home и монтируем в неё subvolume @home
mkdir /mnt/home
mount -o subvol=@home,compress=zstd discard=async /dev/sda2 /mnt/home

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
pacstrap /mnt base base-devel linux linux-firmware vim

# Генерируем fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt

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

# Initramfs
# В файле /etc/mkinitcpio.conf необходимо отредактировать строку
# HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
# и убрать из неё fsck
mkinitcpio -P

# Пароль root
passwd

# Установка загрузчика
pacman -Syy grub-btrfs efibootmgr
grub-install /dev/sda
