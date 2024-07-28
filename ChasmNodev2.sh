#!/bin/bash

# Banner welcome
echo "
                                             _     _ 
            _                               (_)   | |
  ____ ____| |_   ____ _   _ ____ _   _ ___  _  _ | |
 / ___) _  )  _) / ___) | | |  _ \ | | / _ \| |/ || |
| |  ( (/ /| |__| |   | |_| | | | \ V / |_| | ( (_| |
|_|   \____)\___)_|    \____|_| |_|\_/ \___/|_|\____|
                                                     
"

sudo apt-get update && sudo apt-get upgrade -y
sudo apt --fix-broken install -y
sudo apt-get autoremove -y
clear

echo "══════════════════════════════════"
echo "     ══ Input Konfigurasi ══"
echo "══════════════════════════════════"
read -p "══■ ➡️Nama Chasm Scout: " SCOUTNAME
read -p "══■ ➡️UID Scout: " SCOUTUID
read -p "══■ ➡️API Webhook: " WEBHOOKAPI
read -p "══■ ➡️API Groq: " GROQAPI

echo "══ Hapus paket Docker lama"
for paket in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $paket
done

echo "══■ Paket Pendukung Docker ■══"
sudo apt-get install -y ca-certificates curl

echo "══■ kunci GPG Dan Repositori Docker ■══"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "══■ repository Docker ■══"
sudo sh -c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable' > /etc/apt/sources.list.d/docker.list"

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "══■ direktori Chasm ■══"
mkdir -p ~/chasm
cd ~/chasm

cat > .env <<EOF
PORT=3001
LOGGER_LEVEL=debug
ORCHESTRATOR_URL=https://orchestrator.chasm.net
SCOUT_NAME=$SCOUTNAME
SCOUT_UID=$SCOUTUID
WEBHOOK_API_KEY=$WEBHOOKAPI
WEBHOOK_URL=http://$(hostname -I | awk '{print $1}'):3001/
PROVIDERS=groq
MODEL=gemma2-9b-it
GROQ_API_KEY=$GROQAPI
EOF

echo "══■ Start Chasm Scout ■══"
ufw allow 3001
docker pull chasmtech/chasm-scout:latest
docker run -d --restart=always --env-file ./.env -p 3001:3001 --name scout chasmtech/chasm-scout
echo "Chasm Scout sedang berjalan..."

echo "══■ Selesai Install Chasm Check On Dasboard ■══"
rm -- "$0"
