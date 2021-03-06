#!/bin/bash
set -e
set -x
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [[ ! -f PKGBUILD ]]; then
   echo "Missing PKGBUILD"
   exit 1
fi
source PKGBUILD

POOL=$1
if [[ $POOL == "" ]]; then
   echo "Invalid ZFS Pool"
   exit 1
fi

COMMAND=$2
if [[ $COMMAND == "" ]]; then
   COMMAND="/build.sh"
fi

TIMESTAMP=$(date +%s)
RUN_SHA=$(echo -n "${pkgname}@${TIMESTAMP}" | sha256sum | awk '{print $1}')
TARGET_FILESYSTEM="${POOL}/serotina/packages/${pkgname}/${RUN_SHA}"

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo ""
echo " ==> Package name:       ${pkgname}"
echo " ==> target file system: ${TARGET_FILESYSTEM}"

MOST_RECENT_ROOT=$(zfs list -r ${POOL}/serotina/root | sort -r | sed 1d | head -n1 | awk '{print $1}')
echo " ==> root container:     ${MOST_RECENT_ROOT}"

ROOT_SNAPSHOT="${MOST_RECENT_ROOT}@${RUN_SHA}"
echo " ==> taking snapshot:    ${ROOT_SNAPSHOT}"
zfs snapshot ${ROOT_SNAPSHOT}

echo " ==> cloning:            ${ROOT_SNAPSHOT} -> ${TARGET_FILESYSTEM}"
zfs create -p "${POOL}/serotina/packages/${pkgname}"
zfs clone ${ROOT_SNAPSHOT} ${TARGET_FILESYSTEM}

MOUNT_DIR="/tmp/${RUN_SHA}"
echo " ==> mount filesystem:   ${TARGET_FILESYSTEM} to ${MOUNT_DIR}"
zfs set mountpoint=${MOUNT_DIR} ${TARGET_FILESYSTEM}

cat /etc/resolv.conf > ${MOUNT_DIR}/etc/resolv.conf
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > ${MOUNT_DIR}/etc/sudoers

# Setup build script
cp ${SCRIPT_DIR}/build.sh ${MOUNT_DIR}/build.sh
chmod 755 ${MOUNT_DIR}/build.sh

# Persistent cache directory which will be set as the build users home directory
mkdir -p /var/cache/build

# Signing Keys
mkdir -p ${MOUNT_DIR}/home/build/.gnupg
cp -r /var/lib/jenkins/.gnupg ${MOUNT_DIR}/home/build/.gnupg

systemd-nspawn --directory=${MOUNT_DIR} --machine=${pkgname}-${RANDOM} --bind=/var/cache/pacman --bind=/var/cache/build:/home/build --bind=$(pwd):/build --network-veth $COMMAND

echo " ==> destroy ${TARGET_FILESYSTEM}"
zfs destroy -r ${TARGET_FILESYSTEM}
rmdir ${MOUNT_DIR}
