#!/bin/sh

generate_random_password() {
    cat /dev/urandom | tr -cd '[:alnum:]' | fold -w 32 | head -n 1
}

prepare_sshd() {
    SSHD_CUSTOM_CONFIG_FILE="/etc/ssh/sshd_config.d/99-custom-config.conf"

    # Default Config
    export SSHD_CONFIG_PasswordAuthentication=yes

    if ! ls -1 /etc/ssh/ssh_host_*_key &>/dev/null; then
        ssh-keygen -A
    fi

    if [ ! -f "$SSHD_CUSTOM_CONFIG_FILE" ]; then
        env | egrep "^SSHD_CONFIG_" | sed 's/^SSHD_CONFIG_//g' | sed 's/=/ /g' > "$SSHD_CUSTOM_CONFIG_FILE"
    fi
}

prepare_user() {
    echo USER_NAME="${USER_NAME:=alpine}"
    echo USER_GROUP="${USER_GROUP:=alpine}"
    echo USER_PASSWORD="${USER_PASSWORD:=$(generate_random_password)}"
    echo USER_SUDO_ACCESS="${USER_SUDO_ACCESS:=false}"
    echo USER_HOME_DIR="${USER_HOME_DIR:=/home/$USER_NAME}"
    echo USER_PUBLIC_KEYS="$USER_PUBLIC_KEYS"
    echo USER_PUBLIC_KEYS_URL="$USER_PUBLIC_KEYS_URL"

    addgroup "$USER_GROUP"
    adduser -h "$USER_HOME_DIR" \
            -G "$USER_GROUP" \
            -D "$USER_NAME"
    
    CHPASSWD_TEMP_PASSWORDS_FILE="$(mktemp)"
    echo "$USER_NAME:$USER_PASSWORD" > "$CHPASSWD_TEMP_PASSWORDS_FILE"
    chpasswd < "$CHPASSWD_TEMP_PASSWORDS_FILE"
    rm -rf "$CHPASSWD_TEMP_PASSWORDS_FILE"

    if [ "$(echo $USER_SUDO_ACCESS | tr '[:upper:]' '[:lower:]')" = "true" ]; then
        adduser "$USER_NAME" "sudoers"
    fi

    if [ -n "$USER_PUBLIC_KEYS" -o -n "$USER_PUBLIC_KEYS_URL" ]; then
        USER_SSH_DIR="$USER_HOME_DIR/.ssh"
        AUTHORIZED_KEYS_FILE="$USER_SSH_DIR/authorized_keys"

        mkdir "$USER_SSH_DIR"
        chmod 700 "$USER_SSH_DIR"

        if [ -n "$USER_PUBLIC_KEYS" ]; then
            echo "$USER_PUBLIC_KEYS" > "$AUTHORIZED_KEYS_FILE"
        else
            wget -O "$USER_SSH_DIR/authorized_keys" "$USER_PUBLIC_KEYS_URL"
        fi

        chmod 600 "$USER_SSH_DIR/authorized_keys"
        chown -R "$USER_NAME:$USER_GROUP" "$USER_SSH_DIR"
    fi
}

prepare_sshd

prepare_user

exec /usr/sbin/sshd -D
