#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: thost96 (thost96)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE


source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc \
  wget
msg_ok "Installed Dependencies"

msg_info "Installing Proxmox Mail Gateway"
RELEASE=$(curl -fsSL https://api.github.com/repos/checkmk/checkmk/tags | grep "name" | awk '{print substr($2, 3, length($2)-4) }' | head -n 1)

wget -q https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
echo "deb http://download.proxmox.com/debian/pmg bookworm pmg-no-subscription" > /etc/apt/sources.list.d/pmg.list
apt-get update
apt-get install -y proxmox-mailgateway-container
msg_ok "Installed Proxmox Backup Server"

motd_ssh
customize

msg_info "Creating Service"
$STD systemctl enable proxmox-mailgateway-container.service
$STD systemctl start proxmox-mailgateway-container.service
msg_ok "Created Service"

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
