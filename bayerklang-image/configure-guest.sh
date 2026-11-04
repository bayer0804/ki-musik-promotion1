#!/bin/sh
set -eu

# Offline image customization. Downloading packages inside libguestfs is unreliable
# on hosted runners. Software installation happens after first boot on the actual VPS.
id bayerki >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo bayerki
passwd -l bayerki || true
install -d -m 0700 -o bayerki -g bayerki /home/bayerki/.ssh
install -m 0600 -o bayerki -g bayerki /root/bayerklang-public.pub /home/bayerki/.ssh/authorized_keys
rm -f /root/bayerklang-public.pub
printf 'xfce4-session\n' > /home/bayerki/.xsession
chown bayerki:bayerki /home/bayerki/.xsession
chmod 0644 /home/bayerki/.xsession

# Temporary bootstrap: change your own password, then sudo asks for it.
mkdir -p /etc/sudoers.d
cat > /etc/sudoers.d/91-bayerklang-bootstrap <<'EOF'
bayerki ALL=(root) NOPASSWD: /usr/bin/passwd bayerki
EOF
chmod 0440 /etc/sudoers.d/91-bayerklang-bootstrap
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-bayerklang.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AllowUsers bayerki
EOF
mkdir -p /opt/bayerklang/compose /opt/bayerklang/data /opt/bayerklang/backups
chmod 0700 /opt/bayerklang/backups
cat > /usr/local/sbin/bayerklang-firstboot.sh <<'EOF'
#!/bin/sh
set -eu
export DEBIAN_FRONTEND=noninteractive
# Permit SSH access before changing any firewall rules.
systemctl enable --now ssh.service
apt-get update
apt-get install -y --no-install-recommends \
  sudo openssh-server ufw fail2ban unattended-upgrades \
  xfce4 xfce4-session xfce4-terminal thunar dbus-x11 \
  xrdp xorgxrdp language-pack-de fonts-dejavu-core \
  docker.io ca-certificates curl
apt-get install -y docker-compose-v2 || true
usermod -aG sudo bayerki
adduser xrdp ssl-cert || true
systemctl enable --now docker.service xrdp.service fail2ban.service
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable
mkdir -p /var/lib/bayerklang
touch /var/lib/bayerklang/firstboot.done
EOF
chmod 0700 /usr/local/sbin/bayerklang-firstboot.sh
cat > /etc/systemd/system/bayerklang-firstboot.service <<'EOF'
[Unit]
Description=BAYERKLANG First Boot Setup
Wants=network-online.target
After=network-online.target ssh.service
ConditionPathExists=!/var/lib/bayerklang/firstboot.done
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/bayerklang-firstboot.sh
Restart=on-failure
RestartSec=60s
[Install]
WantedBy=multi-user.target
EOF
# Existing SSH should remain enabled. Required on first boot to allow recovery.
systemctl enable ssh.service || true
systemctl enable bayerklang-firstboot.service || true
cat > /etc/netplan/99-bayerklang-fallback.yaml <<'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    bayerklang:
      match:
        name: "e*"
      dhcp4: true
      dhcp6: true
      optional: true
EOF
chmod 0600 /etc/netplan/99-bayerklang-fallback.yaml
cloud-init clean --logs || true
