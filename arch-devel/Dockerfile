FROM atomica/arch-base:latest
MAINTAINER Jason R. McNeil <jason@jasonrm.net>

ADD pacman.conf /etc/pacman.conf

RUN pacman --sync --noconfirm --refresh --needed base-devel git && \
    find /var/cache/pacman/pkg -mindepth 1 -delete && \
    mkdir -p /root/.gnupg && \
    pacman-key -r 5EF75572 && pacman-key --lsign-key 5EF75572' && \
    pacman-key -r 0x4466fcf875b1e1ac && pacman-key --lsign-key 0x4466fcf875b1e1ac'
