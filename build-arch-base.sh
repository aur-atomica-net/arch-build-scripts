#!/bin/sh

TIMESTAMP=$(date +%s)
IMAGE_NAME="arch-base"

pacstrap -c -d ${IMAGE_NAME} base || exit 1

tar -C ${IMAGE_NAME} -c . | docker import - "${IMAGE_NAME}:${TIMESTAMP}"

docker tag "${IMAGE_NAME}:${TIMESTAMP}" "${IMAGE_NAME}:latest"
