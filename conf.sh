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

pacman -Sy networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools reflector

# Установка загрузчика
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Включаем NetworkManager
systemctl enable NetworkManager
