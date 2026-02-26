#!/bin/bash
dnf install \
	-y \
	-c ./almalinux-baseos.repo \
	--releasever=10 \
	--repo=baseos \
	--best \
	--installroot=/var/lib/machines/alma10-docker \
	--setopt=install_weak_deps=False \
	almalinux-release dnf glibc-langpack-en yum dnf rootfiles systemd shadow-utils util-linux passwd vim-minimal iproute iputils less hostname dhcpcd yum-utils openssl curl

# add docker-ce repo
systemd-nspawn --quiet --settings=false -D /var/lib/machines/alma10-docker/ /bin/bash -c "dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo"
# install docker-ce
systemd-nspawn --quiet --settings=false -D /var/lib/machines/alma10-docker/ /bin/bash -c "dnf -y install docker-ce --nobest"
# enable docker.socket / docker.service
systemd-nspawn --quiet --settings=false -D /var/lib/machines/alma10-docker/ /bin/bash -c "ln -s '/usr/lib/systemd/system/docker.socket' '/etc/systemd/system/multi-user.target.wants/docker.socket'"
#systemd-nspawn --quiet --settings=false -D /var/lib/machines/alma10-docker/ /bin/bash -c "ln -s '/usr/lib/systemd/system/docker.service' '/etc/systemd/system/multi-user.target.wants/docker.service'"

# copy nspawn file in place
mkdir -p /etc/systemd/nspawn 2>/dev/null
cp alma10-docker.nspawn /etc/systemd/nspawn

# Because there is no NetworkManager and no systemd-networkd
# in our simplified container we need some other mechanism to
# bring the interface (host0) up and to request a dhcp address
# via dhcpcd
# 
# The systemd service below will do exactly that.
#
#
# create /usr/lib/systemd/system/network-ifup-and-dhcp.service
cat <<-EOF > '/var/lib/machines/alma10-docker/usr/lib/systemd/system/network-ifup-and-dhcp.service'
########################################################
# /usr/lib/systemd/system/network-ifup-and-dhcp.service
########################################################
[Unit]
Description=Bring up host0 interface
Before=network-online.target
#RequiredBy=

[Service]
Type=exec
#Type=oneshot
ExecStartPre=/bin/echo 'trying to bring interface host0 up...'
ExecStartPre=/sbin/ip link set dev host0 up
ExecStartPre=/bin/bash -c 'if /bin/cat /sys/devices/virtual/net/host0/carrier >/dev/null 2>&1; then /bin/echo "host0 is up";else /bin/echo "host0 is down";fi'
ExecStart=/usr/sbin/dhcpcd -d --noarp -b host0
RemainAfterExit=yes

[Install]
WantedBy=network-pre.target
########################################################
EOF
# create symlink to enable the service
ln -sf '/var/lib/machines/almalinux-docker/usr/lib/systemd/system/network-ifup-and-dhcp.service' '/var/lib/machines/alma10-docker/etc/systemd/system/multi-user.target.wants/network-ifup-and-dhcp.service'
