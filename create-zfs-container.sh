#!/bin/bash

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

TIMESTAMP=$(date +%s)
RUN_SHA=$(echo -n "${pkgname}@${TIMESTAMP}" | shasum | awk '{print $1}')

TARGET_FILESYSTEM="${POOL}/serotina/packages/${pkgname}/${RUN_SHA}"

echo ""
echo " ==> Package name:       ${pkgname}"
echo " ==> target file system: ${TARGET_FILESYSTEM}"

MOST_RECENT_ROOT=$(zfs list -r ${POOL}/serotina/root | sort | sed 1d | head -n1 | awk '{print $1}')
echo " ==> root container:     ${MOST_RECENT_ROOT}"

ROOT_SNAPSHOT="${MOST_RECENT_ROOT}@${RUN_SHA}"
echo " ==> taking snapshot:    ${ROOT_SNAPSHOT}"
zfs snapshot ${ROOT_SNAPSHOT} || exit 1

echo " ==> cloning:            ${ROOT_SNAPSHOT} -> ${TARGET_FILESYSTEM}"
zfs create -p "${POOL}/serotina/packages/${pkgname}" || exit 1
zfs clone ${ROOT_SNAPSHOT} ${TARGET_FILESYSTEM} || exit 1

MOUNT_DIR="/tmp/${RUN_SHA}"
echo " ==> mount filesystem:   ${TARGET_FILESYSTEM} to ${MOUNT_DIR}"
zfs set mountpoint=${MOUNT_DIR} ${TARGET_FILESYSTEM} || exit 1

cat <<EOT >> ${MOUNT_DIR}/etc/pacman.conf
[atomica]
Server = https://s3.amazonaws.com/atomica/arch/\$repo/\$arch
SigLevel = Never
EOT

cat /etc/resolv.conf > ${MOUNT_DIR}/etc/resolv.conf
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > ${MOUNT_DIR}/etc/sudoers

# Make sure the build script is executable
chmod 755 ${MOUNT_DIR}/build.sh
systemd-nspawn --directory=${MOUNT_DIR} --bind=/var/cache/pacman/pkg --bind=$(pwd):/build --network-veth /build.sh

echo " ==> destroy ${TARGET_FILESYSTEM}"
zfs destroy -r ${TARGET_FILESYSTEM} || exit 1
rmdir ${MOUNT_DIR}

# rm /atomica/arch/x86_64/${pkgname}*.pkg.tar.xz || true
# cp ${pkgname}*-any.pkg.tar.xz /atomica/arch/x86_64/ || true
# cp ${pkgname}*-x86_64.pkg.tar.xz /atomica/arch/x86_64/ || true
