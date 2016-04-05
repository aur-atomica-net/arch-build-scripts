#!/bin/bash
set -e
set -x
set -o pipefail

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
zfs create -p -o mountpoint=legacy ${FILESYSTEM}

echo " ==> mount filesystem:   ${FILESYSTEM}"
mkdir ${MOUNT_DIR}
mount -t zfs ${FILESYSTEM} ${MOUNT_DIR}

echo " ==> installing packages"
pacstrap -c -d ${MOUNT_DIR} base base-devel ccache

# Add aur.atomica.net repo
cp ${SCRIPT_DIR}/pacman.conf ${MOUNT_DIR}/etc/pacman.conf
mkdir -p ${MOUNT_DIR}/root/.gnupg
systemd-nspawn --directory=${MOUNT_DIR} --bind=/var/cache/pacman /bin/sh -c 'pacman-key -r 5EF75572 && pacman-key --lsign-key 5EF75572'
systemd-nspawn --directory=${MOUNT_DIR} --bind=/var/cache/pacman /bin/sh -c 'pacman-key -r 0x4466fcf875b1e1ac && pacman-key --lsign-key 0x4466fcf875b1e1ac'

# Copy current system makepkg.conf
cp /etc/makepkg.conf ${MOUNT_DIR}/etc/makepkg.conf

echo " ==> unmount filesystem: ${FILESYSTEM}"
umount ${MOUNT_DIR}
rmdir ${MOUNT_DIR}
