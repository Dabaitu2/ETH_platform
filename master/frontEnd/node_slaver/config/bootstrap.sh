#!bin/bash
nohup geth --rpcapi eth,web3,admin,miner,personal,clique --rpc --rpcaddr="0.0.0.0" --rpccorsdomain="*" --maxpeers '5' --networkid '1922' --datadir '/opt/privatechain' --syncmode "full" --unlock "8dd2ac28a87fbe6615395066077935df9eab91ed" --password "/opt/password.txt" --cache=2048 &
cd /opt/node
npm run dev
