#!/bin/bash

#
dhcpcd host0

# Update packages
pacman -Suy --noconfirm

useradd -m -g users -G wheel -s /bin/bash build
chown -R build:users /build
cd /build

if [[ -f ./pre_build.sh ]]; then
    ./pre_build.sh
fi

sudo -u build makepkg --noconfirm --syncdeps ${MAKEPKG_OPTIONS}

if [[ -f ./post_build.sh ]]; then
    ./post_build.sh
fi
