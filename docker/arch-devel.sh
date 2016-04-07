#!/bin/sh
set -e
set -x
set -o pipefail

pacman -Sy --noconfirm base-devel git

# Setup our build user (makepkg doesn't run as root)
groupadd -r -g 1000 build
useradd -g build -G wheel -u 1000 -s /bin/bash build
mkdir -p /home/build
mkdir -p /home/build/.gnupg
echo 'keyserver hkp://pool.sks-keyservers.net' > /home/build/.gnupg/gpg.conf
echo 'keyserver-options auto-key-retrieve' >> /home/build/.gnupg/gpg.conf
chown -R build:build /home/build
