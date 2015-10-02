#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

POOL=$1
if [[ $POOL == "" ]]; then
   echo "Invalid ZFS Pool"
   exit 1
fi

TIMESTAMP=$(date +%s)
FILESYSTEM="${POOL}/serotina/root/${TIMESTAMP}"
MOUNT_DIR=/tmp/serotina_root_${TIMESTAMP}

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo ""

echo " ==> create filesystem:  ${FILESYSTEM}"
zfs create -p -o mountpoint=legacy ${FILESYSTEM} || exit 1

echo " ==> mount filesystem:   ${FILESYSTEM}"
mkdir ${MOUNT_DIR} || exit 1
mount -t zfs ${FILESYSTEM} ${MOUNT_DIR} || exit 1

echo " ==> installing packages"
pacstrap -c -d ${MOUNT_DIR} base base-devel ccache || exit 1

# Add aur.atomica.net repo
cp ${SCRIPT_DIR}/pacman.conf ${MOUNT_DIR}/etc/pacman.conf
mkdir -p ${MOUNT_DIR}/root/.gnupg
systemd-nspawn --directory=${MOUNT_DIR} --bind=/var/cache/pacman /bin/sh -c 'pacman-key -r 5EF75572 && pacman-key --lsign-key 5EF75572' || exit 1

# Copy custom makepkg.conf
cp ${SCRIPT_DIR}/makepkg.conf ${MOUNT_DIR}/etc/makepkg.conf || exit 1

echo " ==> unmount filesystem: ${FILESYSTEM}"
umount ${MOUNT_DIR} || exit 1
rmdir ${MOUNT_DIR} || exit 1
