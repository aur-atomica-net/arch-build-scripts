#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

IMAGE_PREFIX="atomica/"
IMAGE_NAME="arch-base"
TARGET_DIR="tmp/${IMAGE_NAME}"

rm -rf "tmp"
mkdir "${TARGET_DIR}"

pacstrap -c -G -d ${TARGET_DIR} base || exit 1

tar -C ${TARGET_DIR} -c . | docker import - "${IMAGE_PREFIX}${IMAGE_NAME}:latest"
