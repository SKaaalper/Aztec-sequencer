#!/bin/bash

CYAN='\033[0;36m'
LIGHTBLUE='\033[1;34m'
RED='\033[1;31m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
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

echo -e "${YELLOW}${BOLD}🚀 Aztec Sequencer Node Installation${RESET}"
echo -e "📣 TG Group: ${MAGENTA}https://t.me/KatayanAirdropGnC${RESET}"
sleep 2

print_step() {
  echo -e "\n${LIGHTBLUE}$1${RESET}"
}

fail_exit() {
  echo -e "${RED}❌ $1 failed. Exiting.${RESET}"
  exit 1
}

print_step "🔧 Updating system and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y || fail_exit "System update"
sudo apt install -y curl wget iptables build-essential git lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip || fail_exit "Dependency installation"

print_step "${PURPLE}🐳 Installing Docker...${RESET}"
sudo apt-get install -y ca-certificates curl gnupg || fail_exit "Install CA & tools"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || fail_exit "Docker install"
sudo systemctl enable docker
sudo systemctl restart docker

print_step "${PURPLE}📦 Installing Aztec CLI tools...${RESET}"
bash -i <(curl -s https://install.aztec.network) || fail_exit "Aztec install"

echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.aztec/bin:$PATH"

print_step "${CYAN}🔄 Updating Aztec to alpha-testnet...${RESET}"
aztec-up alpha-testnet || fail_exit "Aztec update"

print_step "📦 Pulling Aztec Docker image..."
sudo docker pull aztecprotocol/aztec:alpha-testnet || fail_exit "Docker image pull"

print_step "${GREEN}✅ Verifying Aztec installation...${RESET}"
aztec --version || fail_exit "Aztec verification"

print_step "${YELLOW}🔓 Allowing firewall ports 40400 and 8080...${RESET}"
sudo ufw allow 40400 || fail_exit "UFW port 40400"
sudo ufw allow 8080 || fail_exit "UFW port 8080"

print_step "${MAGENTA}📝 Collecting required details for sequencer setup:${RESET}"
read -p "🛰️  Sepolia RPC URL: " SEPOLIA_RPC
read -p "🔗 Consensus Host URL (Beacon Chain): " CONSENSUS_HOST
read -p "🔑 Your Private Key (start with 0x): " PRIVATE_KEY
read -p "🏦 Your Wallet Address (start with 0x): " WALLET_ADDRESS
IP_ADDR=$(curl -s ifconfig.me)
echo "🌐 Detected IP address: $IP_ADDR"

# Create start_aztec_node.sh script
cat << EOF > $HOME/start_aztec_node.sh
#!/bin/bash
export SEPOLIA_RPC=$SEPOLIA_RPC
export CONSENSUS_HOST=$CONSENSUS_HOST
export PRIVATE_KEY=$PRIVATE_KEY
export WALLET_ADDRESS=$WALLET_ADDRESS
export IP_ADDR=$IP_ADDR

aztec start --node --archiver --sequencer \\
  --network alpha-testnet \\
  --l1-rpc-urls \$SEPOLIA_RPC \\
  --l1-consensus-host-urls \$CONSENSUS_HOST \\
  --sequencer.validatorPrivateKey \$PRIVATE_KEY \\
  --sequencer.coinbase \$WALLET_ADDRESS \\
  --p2p.p2pIp \$IP_ADDR | tee -a \$HOME/aztec_log.txt

tail -f \$HOME/aztec_log.txt
EOF

chmod +x $HOME/start_aztec_node.sh
screen -dmS aztec $HOME/start_aztec_node.sh

print_step "🎉 ${YELLOW}Setup Complete!${RESET}"
echo "🖥️  To check the sequencer logs, run: screen -r aztec"
echo "🔌 To detach from screen, press CTRL+A then D"
echo "📝 Log file: $HOME/aztec_log.txt"
