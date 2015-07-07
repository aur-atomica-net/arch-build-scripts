#!/bin/bash

dhcpcd host0

pacman --sync --sysupgrade --refresh --noconfirm

useradd -m -g users -G wheel -s /bin/bash build
chown -R build:users /build
cd /build

if [[ -f ./pre_build.sh ]]; then
    ./pre_build.sh || exit 1
fi

if [[ "${PRE_INSTALL_PACKAGES}" != "" ]]; then
	pacman -Sy ${PRE_INSTALL_PACKAGES}
fi
sudo -u build makepkg --noconfirm --syncdeps ${MAKEPKG_OPTIONS} || exit 1

if [[ -f ./post_build.sh ]]; then
    ./post_build.sh || exit 1
fi
