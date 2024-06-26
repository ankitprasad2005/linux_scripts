#! /bin/sh

# Script for installing after creating partitions, installing basics, and genfstab.
# Unneat, needs a lot of cleanup and fancy options

# Legacy boot
#cfdisk /dev/sda
#mkfs.ext4 /dev/sda1
#mount /dev/sda3 /mnt

# UEFI boot
#sgdisk -o -n 1:0:+10M -t 1:EF02 -n 2:0:+500M -t 2:EF00 -n 3:0:0 -t 3:8300 /dev/sda
#mkfs.fat -F32 /dev/sda2
#mkfs.ext4 /dev/sda3
#mount /dev/sda3 /mnt
#mkdir /mnt/boot
#mount /dev/sda2 /mnt/boot

#pacstrap -K /mnt base linux linux-firmware neovim nano
#genfstab -U /mnt > /mnt/etc/fstab
#arch-chroot /mnt
# Run the script once chrooted.

set -e
# Confirmation prompt
read -s -n 1 -p 'Are you sure that you have gone through the variables before running? (y/n): ' ans
[[ $ans = 'y' ]] || exit 1

_HOSTNAME="Zephyrus"
_USERNAME="ankit"
_DISK="/dev/nvme0n1"

# Very Important:
alias echo="echo -e"

# set local time
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "${_HOSTNAME}" > /etc/hostname

# Hosts
echo "\n\n127.0.0.1	localhost\n::1		localhost\n127.0.1.1	${_HOSTNAME}.localdomain ${_HOSTNAME}" >> /etc/hosts

mkinitcpio -P

# Password
passwd

pacman -S iwd ranger grub neovim sudo efibootmgr linux-headers

systemctl enable iwd.service

useradd -m ${_USERNAME}
passwd ${_USERNAME}

usermod -aG wheel,audio,video,optical,storage,network,input ${_USERNAME}

# DNS server
# echo "DNS=1.1.1.1" >> /etc/systemd/resolved.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
systemctl enable systemd-resolved.service

# Legacy boot
#grub-install $_DISK
# UEFI boot
#grub-install --target=i386-pc --recheck $_DISK
#grub-install --target=x86_64-efi --efi-directory=/boot/efi --recheck --removable

#grub-mkconfig -o /boot/grub/grub.cfg

#systemctl poweroff
