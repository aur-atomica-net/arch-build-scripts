#!/bin/sh
set -e
set -x
set -o pipefail

pacman -Sy --noconfirm base-devel git
