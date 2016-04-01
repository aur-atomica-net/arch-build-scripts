#!/bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

TIMESTAMP=$(date +%s)
IMAGE_NAME="arch-base"

rm -rf "${IMAGE_NAME}"
mkdir "${IMAGE_NAME}"

pacstrap -c -G -d ${IMAGE_NAME} base || exit 1

tar -C ${IMAGE_NAME} -c . | docker import - "${IMAGE_NAME}:${TIMESTAMP}"

docker tag "${IMAGE_NAME}:${TIMESTAMP}" "${IMAGE_NAME}:latest"
