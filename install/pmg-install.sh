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
$STD apt-get -qq -y install \
  curl \
  sudo \
  mc \
  wget
msg_ok "Installed Dependencies"

msg_info "Installing Proxmox Mail Gateway"
wget -q https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
echo "deb http://download.proxmox.com/debian/pmg bookworm pmg-no-subscription" > /etc/apt/sources.list.d/pmg.list
$STD apt-get -qq update >/dev/null && apt-get -qq -y install proxmox-mailgateway-container >/dev/null
msg_ok "Installed Proxmox Mail Gateway"

# read -r -p "Would you like run Proxmox Mail Gateway Post Install script now? <y/N> " prompt
# if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
#   msg_info "Running Proxmox Mail Gateway Post Install"
#   $STD bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pmg-install.sh)"
#   msg_ok "Successfully run Proxmox Mail Gateway Post Install"
# fi

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
