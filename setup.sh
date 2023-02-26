#!/bin/bash

SCRIPT_DIR=$(dirname $(realpath -s $0))
SCRIPT_PARENT_DIR=$(dirname "$SCRIPT_DIR")
cd "$SCRIPT_DIR" || exit

# Copy .env
cp .env.example .env
echo "[INFO] Created '.env' file"

# Git clone
cd "$SCRIPT_PARENT_DIR" || exit
echo "[INFO] Cloning repositories"
git clone https://github.com/ZINC-FYP-2022-23/console.git
git clone https://github.com/ZINC-FYP-2022-23/hasura-server.git
git clone https://github.com/ZINC-FYP-2022-23/student-ui.git
git clone https://github.com/ZINC-FYP-2022-23/webhook.git
git clone https://gitlab.com/zinc-stack/grader.git

# Set up `grader-daemon` folder
cd "$SCRIPT_PARENT_DIR" || exit
echo "[INFO] Setting up '$SCRIPT_PARENT_DIR/grader-daemon' folder"
mkdir grader-daemon/ && cd grader-daemon || exit
mkdir -p log out shared/extracted shared/generated shared/helpers shared/submitted

# Set up `local-server` folder
echo "[INFO] Setting up '$SCRIPT_PARENT_DIR/local-server' folder"
cd "$SCRIPT_DIR" || exit

# Set up `config.properties` by replacing `${PARENT_DIR}` with the parent directory of this script
sed -e "s|\${PARENT_DIR}|$SCRIPT_PARENT_DIR|" config.example.properties > config.properties
echo "[INFO] Created 'config.properties' file"

# Set up `cloudflared-config.yml` by replacing `${LOCAL_IP}` with the local IP address
LOCAL_IP=$(ip -4 a show wlo1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -z "$LOCAL_IP" ]; then
    echo "[ERROR] Failed to get your local IP address. Please set it manually in the file 'cloudflared-config.yml'."
    cp cloudflared-config.example.yml cloudflared-config.yml
else
    sed -e "s|\${LOCAL_IP}|$LOCAL_IP|" cloudflared-config.example.yml > cloudflared-config.yml
    echo "[INFO] Created 'cloudflared-config.yml' file"
fi

echo "[INFO] Setup script complete. Please go through the README.md file for further instructions."