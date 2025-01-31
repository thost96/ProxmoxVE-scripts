#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: thost96 (thost96)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://docs.mailcow.email/getstarted/install/


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
  git
msg_ok "Installed Dependencies"

# Docker Install
get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}
DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
DOCKER_COMPOSE_LATEST_VERSION=$(get_latest_release "docker/compose")
msg_info "Installing Docker $DOCKER_LATEST_VERSION"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
$STD sh <(curl -sSL https://get.docker.com)
msg_ok "Installed Docker $DOCKER_LATEST_VERSION"

msg_info "Installing Docker Compose Plugin"
$STD apt-get -qq -y install docker-compose-plugin
msg_ok "Installed Docker Compose Plugin"

# mailcow Install
msg_info "Installing mailcow: dockerized latest version"
$STD git clone https://github.com/mailcow/mailcow-dockerized /opt/mailcow-dockerized
#msg_info "Generating Default Config"
#$STD /opt/mailcow-dockerized/generate_config.sh
msg_ok "Installed mailcow: dockerized"

msg_info "Pulling mailcow: dockerized Images"
$STD cd /opt/mailcow-dockerized/ && docker compose pull
msg_ok "Pulled mailcow: dockerized"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/checkmk.deb
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
