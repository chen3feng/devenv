#!/bin/bash

if [[ "$(id -u)" -ne 0 || -z "$SUDO_USER" ]]; then
    echo "Please run this command with sudo." >/dev/stderr
    exit 1
fi

if ! id -nG "$SUDO_USER" | grep -qw "docker"; then
    echo "User '$SUDO_USER' is NOT in the 'docker' group."
    if ! getent group docker >/dev/null; then
        groupadd docker;
    fi
    usermod -aG docker $SUDO_USER
fi

chown root:docker /var/run/docker.sock
chmod 660 /var/run/docker.sock
