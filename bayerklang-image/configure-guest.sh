#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -qy --no-install-recommends \
  openssh-server sudo cloud-init cloud-guest-utils ufw fail2ban \
  unattended-upgrades ca-certificates curl xfce4 xfce4-session \
  xfce4-terminal thunar dbus-x11 xrdp xorgxrdp \
  language-pack-de fonts-dejavu-core docker.io
apt-get install -qy docker-compose-v2 || echo 'Docker Compose v2 needs later setup'
id -u bayerki >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo bayerki
passwd -l bayerki || true
install -d -m 0700 -o bayerki -g bayerki /home/bayerki/.ssh
install -m 0600 -o bayerki -g bayerki /root/bayerklang-public.pub /home/bayerki/.ssh/authorized_keys
rm -f /root/bayerklang-public.pub
printf 'xfce4-session\n' >/home/bayerki/.xsession
chown bayerki:bayerki /home/bayerki/.xsession
chmod 0644 /home/bayerki/.xsession
cat >/etc/sudoers.d/91-bayerklang-bootstrap <<'EOF'
bayerki ALL=(ALL:ALL) NOPASSWD:ALL
EOF
chmod 0440 /etc/sudoers.d/91-bayerklang-bootstrap
cat >/etc/ssh/sshd_config.d/00-bayerklang.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AllowUsers bayerki
EOF
mkdir -p /opt/bayerklang/compose /opt/bayerklang/data /opt/bayerklang/backups
chmod 0700 /opt/bayerklang/backups
cat >/usr/local/sbin/bayerklang-firstboot.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
ssh-keygen -A
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable
systemctl enable ssh.service xrdp.service docker.service fail2ban.service
systemctl restart ssh.service xrdp.service
mkdir -p /var/lib/bayerklang
touch /var/lib/bayerklang/firstboot.done
EOF
chmod 0700 /usr/local/sbin/bayerklang-firstboot.sh
cat >/etc/systemd/system/bayerklang-firstboot.service <<'EOF'
[Unit]
Description=BAYERKLANG First Boot Configuration
After=local-fs.target
Before=ssh.service
ConditionPathExists=!/var/lib/bayerklang/firstboot.done
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/bayerklang-firstboot.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
systemctl enable bayerklang-firstboot.service
systemctl enable ssh.service xrdp.service docker.service fail2ban.service
cat >/etc/netplan/99-bayerklang-fallback.yaml <<'EOF'
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
apt-get clean
rm -rf /var/lib/apt/lists/*
