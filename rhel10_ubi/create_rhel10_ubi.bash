#!/bin/bash

dnf install -y \
	--releasever=10 \
        --repofrompath=ubi10-baseos,https://cdn-ubi.redhat.com/content/public/ubi/dist/ubi10/10/x86_64/baseos/os/ \
	--best \
	--installroot=/var/lib/machines/rhel10-ubi \
        --setopt=install_weak_deps=False \
        --nogpgcheck \
        systemd bash coreutils dnf glibc-langpack-en yum rootfiles shadow-utils util-linux passwd vim-minimal iproute iputils less hostname subscription-manager
mkdir -p /etc/systemd/nspawn 2>/dev/null
cp rhel10-ubi.nspawn /etc/systemd/nspawn

echo "Since this is RHEL you need to register the system to use it."
echo "  subscription-manager register"
echo "To manage it via the cloud console install the insights-client"
echo "and register the system."
echo "  dnf install -y insights-client"
echo "  insights-client --register"
