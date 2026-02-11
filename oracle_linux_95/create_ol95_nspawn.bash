#!/bin/bash
dnf install \
	--nogpgcheck \
	-y \
	-c ./oracle.repo \
	--releasever=9.5 \
	--repo=ol9_baseos_latest \
	--best \
	--installroot=/var/lib/machines/ol95 \
	--setopt=install_weak_deps=False \
	oraclelinux-release-el9 dnf glibc-langpack-en yum dnf rootfiles systemd shadow-utils util-linux passwd vim-minimal iproute iputils less hostname
mkdir -p /etc/systemd/nspawn 2>/dev/null
cp ol95.nspawn /etc/systemd/nspawn
