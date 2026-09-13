#!/bin/bash
set -e

SSH_USER="villagee"
SSH_PASSWORD="VILLAGEE@121"
SSH_PORT="${SSH_PORT:-22}"

# Create SSH user
if ! id "$SSH_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$SSH_USER"
fi
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo "$SSH_USER"
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$SSH_USER"
chmod 440 "/etc/sudoers.d/$SSH_USER"

# SSH config
mkdir -p /run/sshd
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/railway.conf <<EOF
Port $SSH_PORT
ListenAddress 0.0.0.0
PasswordAuthentication yes
KbdInteractiveAuthentication no
PermitRootLogin no
UsePAM no
X11Forwarding no
PrintMotd no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

ssh-keygen -A
/usr/sbin/sshd -t

echo "======================================"
echo " SSH READY on port $SSH_PORT"
echo " User: $SSH_USER"
echo "======================================"

exec /usr/sbin/sshd -D -e
