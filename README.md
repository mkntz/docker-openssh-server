# docker-openssh-server

A Docker image for running instances of the OpenSSH server.

## Getting Started

To run the OpenSSH server, execute the following command:

```bash
docker run --detach \
           --name openssh-server \
           --publish 2222:22 \
           ghcr.io/mkntz/openssh-server:10.0p2
```

## Environment Variables

Refer to the [.env.sample](.env.sample) file for a comprehensive example of the environment variables. Copy this file to `.env`, update it with your desired values, and pass it to the `docker run` command as shown below:

```bash
docker run --detach \
           --name openssh-server \
           --env-file .env \
           --publish 2222:22 \
           ghcr.io/mkntz/openssh-server:10.0p2
```

### OpenSSH Server Configuration

You can pass any parameters from the `sshd_config` file by prepending them with `SSHD_CONFIG_`. For example, to allow TCP forwarding, set the environment variable `SSHD_CONFIG_AllowTcpForwarding` to `yes`.

> **Note:** You can configure the server port using either the `SSHD_CONFIG_Port` or `PORT` environment variables. The `SSHD_CONFIG_Port` variable takes precedence.

### Root User Configuration

#### ROOT_PUBLIC_KEYS

To directly provide public keys, use this variable. _(Separate multiple keys with `\n`.)_

#### ROOT_PUBLIC_KEYS_URL

To specify public keys via a GitHub-like URL (`https://github.com/[username].keys`), use this variable.

> **Note:** The `ROOT_PUBLIC_KEYS` and `ROOT_PUBLIC_KEYS_URL` variables are mutually exclusive; only one will be processed, with `ROOT_PUBLIC_KEYS` taking priority.

### Login User Configuration

#### USER_NAME

Set a custom name for the login user with this variable. (Default: `<random string>`)

#### USER_GROUP

Set a custom group name for the login user using this variable. (Default: `<username>`)

#### USER_PASSWORD

Use this variable to set a password for the login user. (Default: `<random string>`)

#### USER_SUDO_ACCESS

To grant the login user `sudo` privileges, set this variable to `true`. (Default: `false`)

#### USER_HOME_DIR

This variable defines the home directory path for the login user. (Default: `/home/<username>`)

#### USER_PUBLIC_KEYS

Provide public keys directly using this variable. _(Separate multiple keys with `\n`.)_

#### USER_PUBLIC_KEYS_URL

To specify public keys via a GitHub-like URL (`https://github.com/[username].keys`), use this variable.

> **Note:** The `USER_PUBLIC_KEYS` and `USER_PUBLIC_KEYS_URL` variables are mutually exclusive; only one will be processed, with `USER_PUBLIC_KEYS` taking priority.

## Build Docker Image

To build the Docker image, run the following command:

```bash
docker build --platform "linux/amd64,linux/arm64" \
             --tag openssh-server:10.0p2 .
```
