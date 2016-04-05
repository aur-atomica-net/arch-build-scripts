#!/bin/sh
set -e
set -o pipefail

pacman-key -r 5EF75572 && pacman-key --lsign-key 5EF75572
pacman-key -r 0x4466fcf875b1e1ac && pacman-key --lsign-key 0x4466fcf875b1e1ac

pacman -Sy --noconfirm base-devel git
