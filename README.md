## Aztec Sequencer 1 Click Node Setup Guide

![image](https://github.com/user-attachments/assets/a6ceaf27-df35-48bb-82be-f01e43e784e5)

This guide will help you set up an Aztec Sequencer Node on a Virtual Private Server (VPS). The tutorial was created using Linux (Ubuntu), but the steps may vary slightly for other operating systems.

## Hardware Requirements:
| **Part**       | **Minimum**  | **Recommended** |
|----------------|--------------|----------------|
| **CPU**        | -            | ≥ 8 cores      |
| **RAM**        | -            | 16 GB          |
| **SSD**        | -            | 1 TB           |


## Need VPS?
-  **Guide on how to buy from Contabo** [HERE](https://medium.com/@Airdrop_Jheff/guide-on-how-to-buy-a-vps-server-from-contabo-and-set-it-up-on-termius-0928e0e5cb5d)


### Before running a sequencer, make sure you have Sepolia test tokens:

Faucet:
- [Google Cloud](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
- [Alchemy](https://www.alchemy.com/faucets)
- [Sepolia Mining Faucet](https://sepolia-faucet.pk910.de/)

1. **Use either `curl` or `wget` to execute the following commands and run your Aztec node**:
  - Using `Curl`:
```
bash <(curl -s https://raw.githubusercontent.com/SKaaalper/Aztec-sequencer/main/aztec-install.sh)
```

  - Using `Wget`:
```
bash <(wget -qO- https://raw.githubusercontent.com/SKaaalper/Aztec-sequencer/main/aztec-install.sh)
```
- `<SEPOLIA_RPC>`: Get your Sepolia RPC, Visit [HERE](https://chainlist.org/chain/11155111)
or you can choose 1 here:
  -  `https://sepolia.gateway.tenderly.co`
  -  `https://1rpc.io/sepolia`
  -  `https://ethereum-sepolia-rpc.publicnode.com`
  -  `https://eth-sepolia.public.blastapi.io`

- `<CONSENSUS-HOST-URL>`: You need to use a premium RPC so the blob remains stable, Visit **ANKR** [HERE](https://www.ankr.com/rpc/?utm_referral=9du8k7t88W)
  - Use my referral code to get 20% more free requests for $10 deposit, equivalent to 20 million API credits. `https://www.ankr.com/rpc/?utm_referral=9du8k7t88W`
  - My deposit is $10, but you can deposit $5 using crypto deposit Arb chain (USDC).
  - You can bridge here: https://relay.link/bridge
  - Don’t worry — the request limit on that one doesn’t run out quickly, unlike Sepolia RPC, which gets consumed fast. If you're only using Beacon RPC, the usage is very low. Based on estimates, even a $10 deposit could last for around a year.

![image](https://github.com/user-attachments/assets/9602ae8a-d321-4881-b7ad-e81ec05e40b6)
  
- `<0xYourPrivateKey>`: with your wallet's private key that has SepoliaETH (use a new wallet and don’t forget, Start it with `0x`).
- `<0xYourAddress>`: with the wallet address of the private key above.

![image](https://github.com/user-attachments/assets/d5a38957-b090-4b42-a080-8e820dc81080)

- Wait a 20 to 30 minutes for the sync to complete.
- First, you need to detach from the screen before proceeding to the next step, **Press Ctrl + A, Then Click D**
- **screen Logs**: `screen -r aztec`
- **Docker Logs**:
```
sudo docker logs -f --tail 100 $(docker ps -q --filter ancestor=aztecprotocol/aztec:latest | head -n 1)
```

**If you encounter an error**, [Proceed HERE](https://github.com/SKaaalper/Aztec-sequencer?tab=readme-ov-file#for-existing-users-only-update-your-sequencer-node)
  
**To check your IP address use this command `curl ifconfig.me`,`curl -4 ifconfig.me`**

2. **Get Your Block Number**:
- Once you're outside the session, run the following command. Replace `<YOUR_IP_ADDRESS>` with your `VPS IP`:
```
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://<YOUR_IP_ADDRESS>:8080 | jq -r ".result.proven.number"
```
- This will show your block number — copy and save it.

  ![image](https://github.com/user-attachments/assets/1238a0bc-6a9b-4112-ba2a-2e0d104fbc67)

  
3. **Get Your Proof**:
- Run this command. Replace `<YOUR_IP_ADDRESS>` with your `VPS IP`, and `<BLOCK_NUMBER>` with the block number you just got:
```
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["<BLOCK_NUMBER>","<BLOCK_NUMBER>"],"id":67}' \
http://<YOUR_IP_ADDRESS>:8080 | jq -r ".result"
```
- This will show your proof — copy and save it too.

![image](https://github.com/user-attachments/assets/28570cc8-4774-4e0e-a9b9-79d82d6eccde)


4. **Get your Role**:
- Join the **Aztec Discord** server, Join [HERE](https://discord.gg/aztec)
- Run the command `/operator start` in the **#operator channel**.
- Fill in your **wallet address**, **block number**, and **proof**.

![image](https://github.com/user-attachments/assets/344ab8f8-cdb1-419a-98d0-50113fd1dc7a)

5. **Register Validator**:
```
aztec add-l1-validator \
  --l1-rpc-urls <RPC URL> \
  --private-key <your-private-key> \
  --attester <your-validator-address> \
  --proposer-eoa <your-validator-address> \
  --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
  --l1-chain-id 11155111
```
- Replace `<RPC URL>` , `<your-private-key>` , `<your-validator-address>` (**attester** and **proposer-eoa** is the same address).

**If you encounter this error, it means the validator quota for today is full. You will need to register again by tomorrow**.

![image](https://github.com/user-attachments/assets/b27a887e-bb8e-4d19-8716-352bac2be194)


## (For existing users only): Update your sequencer node:

- **Delete Screen**:
```
screen -XS aztec quit
```

- **Delete `aztec` docker**:
```
docker ps -q --filter "ancestor=aztecprotocol/aztec" | xargs -r docker stop
docker ps -a -q --filter "ancestor=aztecprotocol/aztec" | xargs -r docker rm
```

- **Stop your validator and delete your database**:
```
rm -rf ~/.aztec/alpha-testnet/data/
```

- **Create new `screen`**:
```
screen -S aztec
```
  
- **Update your node, Using `screen`**:
```
aztec-up alpha-testnet
```

- **Now, Start your NODE for `screen`**:
```
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls <YOUR_RPC_URL> \
  --l1-consensus-host-urls <YOUR_BEACON_URL> \
  --sequencer.validatorPrivateKey <YOUR_PRIVATEKEY> \
  --sequencer.coinbase <YOUR_WALLET_ADDRESS> \
  --p2p.p2pIp <YOUR_VPS_IP_ADDRESS> \
  --p2p.maxTxPoolSize 1000000000
```

- To **Detach**: **Press Ctrl + A, Then Click D**

- **docker `Logs`**:
```
sudo docker logs -f --tail 100 $(docker ps -q --filter ancestor=aztecprotocol/aztec:latest | head -n 1)
```

- **screen Logs**: `screen -r aztec`

![image](https://github.com/user-attachments/assets/a0e1af8b-3977-4966-8b1f-ecfb0402e174)


- If you need help, reach out through: [Telegram](https://t.me/KatayanAirdropGnC)

<p align="center">
  <img src="https://komarev.com/ghpvc/?username=SKaaalper&color=yellow" alt="Profile Views" />
</p>
