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

echo ""

echo " ==> create filesystem:  ${FILESYSTEM}"
zfs create -p -o mountpoint=legacy ${FILESYSTEM} || exit 1

echo " ==> mount filesystem:   ${FILESYSTEM}"
mkdir ${MOUNT_DIR} || exit 1
mount -t zfs ${FILESYSTEM} ${MOUNT_DIR} || exit 1

echo " ==> installing packages"
pacstrap -c -d ${MOUNT_DIR} base base-devel || exit 1

echo " ==> unmount filesystem: ${FILESYSTEM}"
umount ${MOUNT_DIR} || exit 1
rmdir ${MOUNT_DIR} || exit 1
