#!/bin/bash

ORANGE='\033[38;5;208m'
TEAL='\033[38;5;37m'
PINK='\033[38;5;213m'
LIME='\033[38;5;118m'
SKY='\033[38;5;123m'
GOLD='\033[38;5;220m'
BOLD='\033[1m'
RESET='\033[0m'

clear
cat << "EOF"
       █████ █████   █████ ██████████ ███████████ ███████████
      ░░███ ░░███   ░░███ ░░███░░░░░█░░███░░░░░░█░░███░░░░░░█
       ░███  ░███    ░███  ░███  █ ░  ░███   █ ░  ░███   █ ░ 
       ░███  ░███████████  ░██████    ░███████    ░███████   
       ░███  ░███░░░░░███  ░███░░█    ░███░░░█    ░███░░░█   
 ███   ░███  ░███    ░███  ░███ ░   █ ░███  ░     ░███  ░    
░░████████   █████   █████ ██████████ █████       █████      
 ░░░░░░░░   ░░░░░   ░░░░░ ░░░░░░░░░░ ░░░░░       ░░░░░       
EOF

echo -e "${GOLD}${BOLD}🚀 Aztec Sequencer Pro Installer${RESET}"
echo -e "📣 TG Group: ${PINK}https://t.me/KatayanAirdropGnC${RESET}"
sleep 2

print_step() {
  echo -e "\n${SKY}$1${RESET}"
}

fail_exit() {
  echo -e "${ORANGE}❌ $1 failed. Exiting.${RESET}"
  exit 1
}

print_step "🔧 Updating system and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y || fail_exit "System update"
sudo apt install -y curl wget iptables build-essential git lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip || fail_exit "Dependency installation"

print_step "${TEAL}📦 Installing Aztec CLI tools...${RESET}"
bash -i <(curl -s https://install.aztec.network) || fail_exit "Aztec install"

echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

print_step "${LIME}🔄 Updating Aztec to alpha-testnet...${RESET}"
aztec-up alpha-testnet || fail_exit "Aztec update"

print_step "${PINK}✅ Verifying Aztec installation...${RESET}"
aztec --version || fail_exit "Aztec verification"

print_step "${GOLD}🔓 Allowing firewall ports 40400 and 8080...${RESET}"
sudo ufw allow 40400 || fail_exit "UFW port 40400"
sudo ufw allow 8080 || fail_exit "UFW port 8080"

print_step "${SKY}📝 Collecting required details for sequencer setup:${RESET}"
read -p "🛰️  Sepolia RPC URL: " SEPOLIA_RPC
read -p "🔗 Consensus Host URL (Beacon Chain): " CONSENSUS_HOST
read -p "🔑 Your Private Key (start with 0x): " PRIVATE_KEY
read -p "🏦 Your Wallet Address (start with 0x): " WALLET_ADDRESS
IP_ADDR=$(curl -s ifconfig.me)
echo "🌐 Detected IP address: $IP_ADDR"

print_step "${TEAL}🚀 Launching Aztec Sequencer in screen session...${RESET}"
screen -dmS aztec bash -ic "\
export SEPOLIA_RPC=$SEPOLIA_RPC; \
export CONSENSUS_HOST=$CONSENSUS_HOST; \
export PRIVATE_KEY=$PRIVATE_KEY; \
export WALLET_ADDRESS=$WALLET_ADDRESS; \
export IP_ADDR=$IP_ADDR; \
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls \$SEPOLIA_RPC \
  --l1-consensus-host-urls \$CONSENSUS_HOST \
  --sequencer.validatorPrivateKey \$PRIVATE_KEY \
  --sequencer.coinbase \$WALLET_ADDRESS \
  --p2p.p2pIp \$IP_ADDR" || fail_exit "Aztec sequencer launch"

print_step "🎉 ${LIME}Setup Complete!${RESET}"
echo "🖥️  To check the sequencer, run: ${SKY}screen -r aztec${RESET}"
echo "🔌 To detach from screen, press ${SKY}CTRL+A then D${RESET}"
