#!bin/bash
cat ~/genesis.json
geth --datadir "~/.ethereum" init ~/genesis.json
nohup geth --rpcapi eth,web3,admin,miner --rpc --rpcaddr="0.0.0.0" --rpccorsdomain="*" --maxpeers '5' --networkid '1922' --datadir '~/Library/Ethereum' &
cd /root/node
npm run dev