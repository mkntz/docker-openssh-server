#!/bin/sh

generate_random_string() {
    local length="${1:-32}"

    cat /dev/urandom | tr -cd '[:alnum:]' | fold -w $length | head -n 1
}

configure_sshd() {
    local SSHD_CUSTOM_CONFIG_FILE="/etc/ssh/sshd_config.d/99-custom-config.conf"

    # Default Config
    export SSHD_CONFIG_PasswordAuthentication=yes

    if ! ls -1 /etc/ssh/ssh_host_*_key &>/dev/null; then
        ssh-keygen -A
    fi

    if [ ! -f "$SSHD_CUSTOM_CONFIG_FILE" ]; then
        env | egrep "^SSHD_CONFIG_" | sed 's/^SSHD_CONFIG_//g' | sed 's/=/ /g' > "$SSHD_CUSTOM_CONFIG_FILE"
    fi
}

configure_root() {
    echo ROOT_NAME="${ROOT_NAME:=root}"
    echo ROOT_GROUP="${ROOT_GROUP:=root}"
    echo ROOT_HOME_DIR="${ROOT_HOME_DIR:=/root}"
    echo ROOT_PUBLIC_KEYS="$ROOT_PUBLIC_KEYS"
    echo ROOT_PUBLIC_KEYS_URL="$ROOT_PUBLIC_KEYS_URL"

    if [ -n "$ROOT_PUBLIC_KEYS" -o -n "$ROOT_PUBLIC_KEYS_URL" ]; then
        local ROOT_SSH_DIR="$ROOT_HOME_DIR/.ssh"
        local ROOT_AUTHORIZED_KEYS_FILE="$ROOT_SSH_DIR/authorized_keys"

        mkdir "$ROOT_SSH_DIR"
        chmod 700 "$ROOT_SSH_DIR"

        if [ -n "$ROOT_PUBLIC_KEYS" ]; then
            echo "$ROOT_PUBLIC_KEYS" > "$ROOT_AUTHORIZED_KEYS_FILE"
        else
            wget -O "$ROOT_AUTHORIZED_KEYS_FILE" "$ROOT_PUBLIC_KEYS_URL"
        fi

        chmod 600 "$ROOT_AUTHORIZED_KEYS_FILE"
        chown -R "$ROOT_NAME:$ROOT_GROUP" "$ROOT_SSH_DIR"
    fi
}

configure_user() {
    echo USER_NAME="${USER_NAME:=$(generate_random_string 16)}"
    echo USER_GROUP="${USER_GROUP:=$USER_NAME}"
    echo USER_PASSWORD="${USER_PASSWORD:=$(generate_random_string)}"
    echo USER_SUDO_ACCESS="${USER_SUDO_ACCESS:=false}"
    echo USER_HOME_DIR="${USER_HOME_DIR:=/home/$USER_NAME}"
    echo USER_PUBLIC_KEYS="$USER_PUBLIC_KEYS"
    echo USER_PUBLIC_KEYS_URL="$USER_PUBLIC_KEYS_URL"

    addgroup "$USER_GROUP"
    adduser -h "$USER_HOME_DIR" \
            -G "$USER_GROUP" \
            -D "$USER_NAME"
    
    local TEMP_CHPASSWD_PASSWORDS_FILE="$(mktemp)"
    echo "$USER_NAME:$USER_PASSWORD" > "$TEMP_CHPASSWD_PASSWORDS_FILE"
    chpasswd < "$TEMP_CHPASSWD_PASSWORDS_FILE"
    rm -rf "$TEMP_CHPASSWD_PASSWORDS_FILE"

    if [ "$(echo $USER_SUDO_ACCESS | tr '[:upper:]' '[:lower:]')" = "true" ]; then
        adduser "$USER_NAME" "sudoers"
    fi

    if [ -n "$USER_PUBLIC_KEYS" -o -n "$USER_PUBLIC_KEYS_URL" ]; then
        local USER_SSH_DIR="$USER_HOME_DIR/.ssh"
        local USER_AUTHORIZED_KEYS_FILE="$USER_SSH_DIR/authorized_keys"

        mkdir "$USER_SSH_DIR"
        chmod 700 "$USER_SSH_DIR"

        if [ -n "$USER_PUBLIC_KEYS" ]; then
            echo "$USER_PUBLIC_KEYS" > "$USER_AUTHORIZED_KEYS_FILE"
        else
            wget -O "$USER_AUTHORIZED_KEYS_FILE" "$USER_PUBLIC_KEYS_URL"
        fi

        chmod 600 "$USER_AUTHORIZED_KEYS_FILE"
        chown -R "$USER_NAME:$USER_GROUP" "$USER_SSH_DIR"
    fi
}

configure_sshd

configure_root

configure_user

exec /usr/sbin/sshd -D
