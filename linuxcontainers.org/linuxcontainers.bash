#!/usr/bin/env bash
set -euo pipefail

# Script to automatically work with linuxcontainers.org images
# and systemd-nspawn

BASE_URL="https://images.linuxcontainers.org/images"

# URL-decode helper (for display and names)
urldecode() {
    local data="${1//+/ }"
    printf '%b' "${data//%/\\x}"
}

# Get subdirectories from a listable indexed page (raw/encoded names)
list_dirs() {
    curl -fsSL "$1" \
    | awk -F'"' '/href="[^"]+\/"/ {print $2}' \
    | grep -vE '(^\.\./?$)' \
    | sed 's:/$::'
}

# Check if rootfs.tar.xz exists in current dir
has_rootfs() {
    curl -fsSL "$1" | grep -q 'rootfs\.tar\.xz'
}

current="$BASE_URL"

while true; do
    echo
    echo "Current URL: $current/"

    if has_rootfs "$current/"; then
        rootfs_url="$current/rootfs.tar.xz"
        echo "Found rootfs.tar.xz:"
        echo "  $rootfs_url"

        # Derive distribution name from the first path component under /images
        rel="${current#${BASE_URL}/}"
        rel="${rel%/}"
        IFS='/' read -r -a parts <<<"$rel"

        distro_raw="${parts[0]}"
        dist_name="$(urldecode "$distro_raw")"

        echo "Suggested name: $dist_name"
        read -rp "Run importctl -m pull-tar --verify=checksum with this? [y/N] " ans
        case "$ans" in
            [Yy]*)
                echo "Running: importctl -m pull-tar --verify=checksum \"$rootfs_url\" \"$dist_name\""
                importctl -m pull-tar --verify=checksum "$rootfs_url" "$dist_name"
                ;;
            *)
                echo "Not running importctl."
                ;;
        esac

        # Create /etc/systemd/nspawn/${dist_name}.nspawn
        nspawn_file="/etc/systemd/nspawn/${dist_name}.nspawn"
        cat > "$nspawn_file" << EOF
[Exec]
Boot=true
PrivateUsers=no
Hostname=${dist_name}

[Network]
Private=no
VirtualEthernet=no

[Files]
# Adds a bind mount from the host into the container.
# Takes a single path, a pair of two paths separated by a colon,
# or a triplet of two paths plus an option string separated by colons.
# 
# /pathhere:/paththere
# /pathhere:/paththere:options
EOF
        rm -f "/var/lib/machines/$dist_name/etc/hostname" 2>/dev/null
        echo "Created systemd-nspawn file: $nspawn_file"
        echo "You can now boot with: systemd-nspawn -M $dist_name --boot"
        break
    fi

    mapfile -t dirs < <(list_dirs "$current/")
    if ((${#dirs[@]} == 0)); then
        echo "No subdirectories and no rootfs.tar.xz here."
        exit 1
    fi

    # Build decoded labels for menu display
    labels=()
    for d in "${dirs[@]}"; do
        labels+=( "$(urldecode "$d")" )
    done

    echo "Select a subdirectory:"
    select lbl in "${labels[@]}" "Quit"; do
        case "$REPLY" in
            '' )
                echo "Invalid choice."
                ;;
            $(( ${#dirs[@]} + 1 )) )
                echo "Bye."
                exit 0
                ;;
            * )
                if (( REPLY >= 1 && REPLY <= ${#dirs[@]} )); then
                    # Use original (possibly encoded) name for URL
                    current="$current/${dirs[REPLY-1]}"
                    break
                else
                    echo "Invalid choice."
                fi
                ;;
        esac
    done
done

