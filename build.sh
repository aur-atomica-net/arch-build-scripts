#!/bin/bash
set -e
set -x
set -o pipefail

# This might not be required in the future
dhcpcd host0

pacman --sync --refresh --noconfirm archlinux-keyring
pacman --sync --sysupgrade --noconfirm

useradd -g users -G wheel -s /bin/bash build
mkdir -p /home/build && chown -R build:users /home/build
chown -R build:users /build

cd /build

sudo -u build mkdir -p /home/build/.gnupg
sudo -u build echo 'keyserver hkp://pool.sks-keyservers.net' > /home/build/.gnupg/gpg.conf
sudo -u build echo 'keyserver-options auto-key-retrieve' >> /home/build/.gnupg/gpg.conf

if [[ -f ./pre_build.sh ]]; then
    chmod 755 ./pre_build.sh
    ./pre_build.sh
fi

sudo -u build makepkg --force --noconfirm --syncdeps --sign --install --nocheck

if [[ -f ./post_build.sh ]]; then
    chmod 755 ./post_build.sh
    ./post_build.sh
fi
