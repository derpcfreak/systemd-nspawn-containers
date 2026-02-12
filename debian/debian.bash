#!/bin/bash

if ! command -v debootstrap >/dev/null 2>&1; then
    echo "command debootstrap is missing, please install it via"
    echo "your package manager or download it e.g. from https://www.rpmfind.net/"
    echo "it usually does not need its normal dependencies (--nodeps)"
else
    debootstrap \
         --arch=amd64 \
	 --include=dbus,libpam-systemd,libnss-systemd stable \
	 /var/lib/machines/debian \
	 http://deb.debian.org/debian/
    mkdir -p /etc/systemd/nspawn 2>/dev/null
    cp debian.nspawn /etc/systemd/nspawn
    # debian seems not to recognize hostname from /etc/systemd/nspawn/debian.nspawn
    # so we fix that manually
    echo 'debian' > /var/lib/machines/debian/etc/hostname
fi
