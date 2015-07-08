#!/bin/bash

# This might not be required in the future
dhcpcd host0

pacman --sync --sysupgrade --refresh --noconfirm

useradd -m -g users -G wheel -s /bin/bash build
chown -R build:users /build
cd /build

if [[ -f ./pre_build.sh ]]; then
    ./pre_build.sh || exit 1
fi

sudo -u build makepkg --noconfirm --syncdeps || exit 1

if [[ -f ./post_build.sh ]]; then
    ./post_build.sh || exit 1
fi
