#!/bin/bash
dnf install \
	--nogpgcheck \
	-y \
	-c ./oracle.repo \
	--releasever=10.0 \
	--repo=ol10_baseos_latest \
	--best \
	--installroot=/var/lib/machines/ol10 \
	--setopt=install_weak_deps=False \
	oraclelinux-release-el10 dnf glibc-langpack-en yum dnf rootfiles systemd shadow-utils util-linux passwd vim-minimal iproute iputils less hostname
mkdir -p /etc/systemd/nspawn 2>/dev/null
cp ol10.nspawn /etc/systemd/nspawn
