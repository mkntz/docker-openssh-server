# OpenSSH Server Docker Image

[![Docker Image](https://img.shields.io/badge/mkntz%2Fopenssh--server-10.2p1-2496ED.svg?logo=docker&logoColor=2496ED&labelColor=whitesmoke)](https://hub.docker.com/r/mkntz/openssh-server)
[![Alpine Version](https://img.shields.io/badge/Alpine-3.23-0D597F.svg?logo=alpinelinux&logoColor=0D597F&labelColor=whitesmoke)](https://alpinelinux.org/)
[![OpenSSH Version](https://img.shields.io/badge/OpenSSH-10.2p1-F2CA30.svg?logo=openbsd&logoColor=F2CA30&labelColor=whitesmoke)](https://www.openssh.com/)

---

## Quick reference

- **Maintained by**: [mkntz](https://github.com/mkntz)
- **Where to get help**: [GitHub Issues](https://github.com/mkntz/docker-openssh-server/issues)
- **Where to file issues**: [GitHub Issues](https://github.com/mkntz/docker-openssh-server/issues)
- **Source of this description**: [GitHub repo README](https://github.com/mkntz/docker-openssh-server)
- **Supported architectures**: `amd64`, `arm64`
- **Image updates**: Automated builds on new Alpine releases and OpenSSH updates

## Supported tags and respective `Dockerfile` links

- [`10.2p1`, `10.2`, `10`, `latest`](https://github.com/mkntz/docker-openssh-server/blob/10.2p1/Dockerfile)
- [`10.0p1`, `10.0`](https://github.com/mkntz/docker-openssh-server/blob/10.0p1/Dockerfile)
- [`9.9p2`, `9.9`, `9`](https://github.com/mkntz/docker-openssh-server/blob/9.9p2/Dockerfile)

---

## Introduction

A lightweight, secure, and highly configurable OpenSSH server Docker image based on Alpine Linux. Perfect for development environments, SSH tunneling, SFTP access, and secure remote access scenarios.

## 🚀 Quick Start

Run an OpenSSH server with randomly generated credentials:

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  mkntz/openssh-server:10.2p1
```

Check the logs to retrieve the generated username and password:

```bash
docker logs openssh-server
```

Connect to your server:

```bash
ssh -p 2222 <username>@localhost
```

## 📋 Features

- **Lightweight**: Based on Alpine Linux for minimal footprint
- **Multi-architecture**: Supports `linux/amd64` and `linux/arm64`
- **Flexible Authentication**: Password and/or SSH key-based authentication
- **Customizable**: Full control over SSH server configuration
- **User Management**: Configurable root and user accounts
- **Security**: Follows OpenSSH best practices
- **Auto-configuration**: Automatically generates host keys and user credentials

## 📖 Usage Examples

### Basic Usage with Custom Credentials

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  -e USER_NAME=myuser \
  -e USER_PASSWORD=mypassword \
  mkntz/openssh-server:10.2p1
```

### SSH Key Authentication

Using direct public keys:

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  -e USER_NAME=myuser \
  -e USER_PUBLIC_KEYS="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host" \
  mkntz/openssh-server:10.2p1
```

Using GitHub public keys:

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  -e USER_NAME=myuser \
  -e USER_PUBLIC_KEYS_URL="https://github.com/username.keys" \
  mkntz/openssh-server:10.2p1
```

### User with Sudo Access

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  -e USER_NAME=admin \
  -e USER_PASSWORD=secure123 \
  -e USER_SUDO_ACCESS=true \
  mkntz/openssh-server:10.2p1
```

### Root Access Configuration

Enable root login with SSH keys:

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  -e ROOT_PUBLIC_KEYS_URL="https://github.com/username.keys" \
  -e SSHD_CONFIG_PermitRootLogin=yes \
  mkntz/openssh-server:10.2p1
```

### Advanced Configuration with Docker Compose

Create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  openssh-server:
    image: mkntz/openssh-server:10.2p1
    container_name: openssh-server
    ports:
      - "2222:22"
    environment:
      - USER_NAME=devuser
      - USER_PASSWORD=devpass123
      - USER_SUDO_ACCESS=true
      - SSHD_CONFIG_AllowTcpForwarding=yes
      - SSHD_CONFIG_GatewayPorts=yes
      - SSHD_CONFIG_PasswordAuthentication=yes
    volumes:
      - ssh-data:/home/devuser
    restart: unless-stopped

volumes:
  ssh-data:
```

Run with:

```bash
docker-compose up -d
```

### Using Environment File

Create an `.env` file:

```env
USER_NAME=myuser
USER_PASSWORD=mypassword
USER_SUDO_ACCESS=true
SSHD_CONFIG_Port=22
SSHD_CONFIG_AllowTcpForwarding=yes
SSHD_CONFIG_PasswordAuthentication=yes
```

Run the container:

```bash
docker run -d \
  --name openssh-server \
  --env-file .env \
  -p 2222:22 \
  mkntz/openssh-server:10.2p1
```

## ⚙️ Configuration

### Environment Variables

#### OpenSSH Server Configuration

You can configure any `sshd_config` parameter by prefixing it with `SSHD_CONFIG_`.

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | SSH server port | `22` |
| `SSHD_CONFIG_Port` | SSH server port (takes precedence over `PORT`) | `22` |
| `SSHD_CONFIG_PasswordAuthentication` | Enable password authentication | `yes` |
| `SSHD_CONFIG_PubkeyAuthentication` | Enable public key authentication | `yes` |
| `SSHD_CONFIG_PermitRootLogin` | Allow root login | `prohibit-password` |
| `SSHD_CONFIG_AllowTcpForwarding` | Allow TCP forwarding | `no` |
| `SSHD_CONFIG_GatewayPorts` | Allow remote hosts to connect to forwarded ports | `no` |
| `SSHD_CONFIG_X11Forwarding` | Enable X11 forwarding | `no` |
| `SSHD_CONFIG_ClientAliveInterval` | Seconds before sending keepalive message | - |
| `SSHD_CONFIG_ClientAliveCountMax` | Maximum keepalive messages | - |

**Example:**

```bash
docker run -d \
  -e SSHD_CONFIG_AllowTcpForwarding=yes \
  -e SSHD_CONFIG_GatewayPorts=clientspecified \
  -e SSHD_CONFIG_ClientAliveInterval=60 \
  -e SSHD_CONFIG_ClientAliveCountMax=3 \
  -p 2222:22 \
  mkntz/openssh-server:10.2p1
```

#### Root User Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `ROOT_PUBLIC_KEYS` | Direct SSH public keys (separate multiple with `\n`) | - |
| `ROOT_PUBLIC_KEYS_URL` | URL to fetch public keys (e.g., GitHub keys URL) | - |

> **Note:** `ROOT_PUBLIC_KEYS` takes precedence over `ROOT_PUBLIC_KEYS_URL`.

#### Login User Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `USER_NAME` | Username for the login user | Random 16-char string |
| `USER_GROUP` | Group name for the login user | Same as `USER_NAME` |
| `USER_PASSWORD` | Password for the login user | Random 32-char string |
| `USER_SUDO_ACCESS` | Grant sudo privileges (`true`/`false`) | `false` |
| `USER_HOME_DIR` | Home directory path | `/home/<username>` |
| `USER_PUBLIC_KEYS` | Direct SSH public keys (separate multiple with `\n`) | - |
| `USER_PUBLIC_KEYS_URL` | URL to fetch public keys (e.g., GitHub keys URL) | - |

> **Note:** `USER_PUBLIC_KEYS` takes precedence over `USER_PUBLIC_KEYS_URL`.

### Multiple SSH Keys

To add multiple SSH keys, separate them with `\n`:

```bash
docker run -d \
  -e USER_PUBLIC_KEYS="ssh-rsa AAAAB3Nza...key1 user1@host\nssh-rsa AAAAB3Nza...key2 user2@host" \
  -p 2222:22 \
  mkntz/openssh-server:10.2p1
```

### Volume Mounts

Mount volumes to persist data or provide additional configuration:

```bash
docker run -d \
  --name openssh-server \
  -p 2222:22 \
  -v /path/to/user/data:/home/myuser \
  -v /path/to/ssh/config:\/etc\/ssh\/sshd_config.d\/custom.conf:ro \
  -e USER_NAME=myuser \
  mkntz/openssh-server:10.2p1
```

## 🔒 Security Recommendations

1. **Disable Password Authentication** (use SSH keys only):

   ```bash
   -e SSHD_CONFIG_PasswordAuthentication=no
   ```

2. **Disable Root Login**:

   ```bash
   -e SSHD_CONFIG_PermitRootLogin=no
   ```

3. **Use Strong Passwords**: If using password authentication, always set strong passwords.

4. **Limit Port Exposure**: Only expose SSH to necessary networks.

5. **Use Docker Networks**: For container-to-container communication, use Docker networks instead of exposing ports.

6. **Regular Updates**: Keep the image updated to receive security patches.

## 🛠️ Common Use Cases

### SSH Tunneling

Create an SSH tunnel for secure database access:

```bash
# Run SSH server with tunneling enabled
docker run -d \
  --name ssh-tunnel \
  -p 2222:22 \
  -e USER_NAME=tunnel \
  -e USER_PASSWORD=secure123 \
  -e SSHD_CONFIG_AllowTcpForwarding=yes \
  mkntz/openssh-server:10.2p1

# Create tunnel from client
ssh -L 5432:database:5432 -p 2222 tunnel@localhost
```

### SFTP Server

Use as an SFTP server for file transfers:

```bash
docker run -d \
  --name sftp-server \
  -p 2222:22 \
  -v /path/to/files:/home/sftpuser/files \
  -e USER_NAME=sftpuser \
  -e USER_PASSWORD=sftppass \
  mkntz/openssh-server:10.2p1

# Connect via SFTP
sftp -P 2222 sftpuser@localhost
```

### Development Environment Access

Provide SSH access to a development container:

```bash
docker run -d \
  --name dev-env \
  -p 2222:22 \
  -v $(pwd)/project:/workspace \
  -e USER_NAME=developer \
  -e USER_SUDO_ACCESS=true \
  -e USER_PUBLIC_KEYS_URL="https://github.com/developer.keys" \
  mkntz/openssh-server:10.2p1
```

## 🐳 Building the Image

### Standard Build

```bash
docker build -t openssh-server:10.2p1 .
```

### Multi-platform Build

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag openssh-server:10.2p1 \
  .
```

## 🔍 Troubleshooting

### View Generated Credentials

```bash
docker logs openssh-server | grep -E "USER_NAME|USER_PASSWORD"
```

### Test SSH Connection

```bash
ssh -v -p 2222 username@localhost
```

### Access Container Shell

```bash
docker exec -it openssh-server sh
```

### Check SSH Server Status

```bash
docker exec openssh-server ps aux | grep sshd
```

### View SSH Configuration

```bash
docker exec openssh-server cat \/etc\/ssh\/sshd_config.d\/99-custom-config.conf
```

## 📝 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📚 Additional Resources

- [OpenSSH Official Documentation](https://www.openssh.com/manual.html)
- [Alpine Linux](https://alpinelinux.org/)
- [Docker Documentation](https://docs.docker.com/)

---

**Repository**: [github.com/mkntz/docker-openssh-server](https://github.com/mkntz/docker-openssh-server)
