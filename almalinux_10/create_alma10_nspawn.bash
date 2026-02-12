#!/bin/bash
dnf install \
	-y \
	-c ./almalinux-baseos.repo \
	--releasever=10 \
	--repo=baseos \
	--best \
	--installroot=/var/lib/machines/alma10 \
	--setopt=install_weak_deps=False \
	almalinux-release dnf glibc-langpack-en yum dnf rootfiles systemd shadow-utils util-linux passwd vim-minimal iproute iputils less hostname
mkdir -p /etc/systemd/nspawn 2>/dev/null
cp alma10.nspawn /etc/systemd/nspawn
