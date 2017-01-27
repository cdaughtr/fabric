#Fabric Multichannel Join functionality test steps:

Clone latest [Fabric repo](https://github.com/hyperledger/fabric.git) and follow below instructions to create and join channels. We have stored cert files in *tmp* direcrtory. Please follow the below directory structure as mentioned in the multichannel directory.

##Important Notes:

 1) Before start network make sure you killed all active containers.
 2) Make sure chaincode is not existed.. If it is, please modify the above commands while creating channel.
 3) Make sure you have latest fabric code. While deploying chaincode from CLI container, it look for example02 program in your local fabric git repo example02 program.

Execute below command to spinup 3 peer, 1 orderer **(solo)** and ca containers. Once the command is executed successfully execute `docker ps` to see the active containers running. 

`docker-compose -f docker-compose-channel.yml up -d --force-recreate`

Now the fabric network is ready.. Execute below commands in CLI container.

`docker exec -it cli sh`. Follow below commands to **create channel, Join channel and submit deploy, invoke and query** on any peer after joining channels on all peers.

### Create Channel
`CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer channel create -c myc1`
### Join Channel on peer0
`CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer0:7051 peer channel join -b myc1.block`

If you are intrested to join channel on other peers ex: peer1 or peer2 modify **peer0:7051** to **peer1:7051** etc.. Same applies to Deploy, Invoke and Query commnds. Once the peers are joined in channel, you can query the result from any peer without deploying chaincode on each peer.

#### Deploy on Peer0
`CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode deploy -C myc1 -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}'`
####Invoke on Peer0
`CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode invoke -C myc1 -n mycc -cIm '{"Args":["invoke","a","b","10"]}'`
####Query on peer0
`CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode query -C myc1 -n mycc -c '{"Args":["query","a"]}'`

## How to run peer on couchdb

`docker-compose-couchdb.yml` file is having couchdb configuration. Just run this yml file and execute above commands to play with channel creation and join. Once the deploy is successfull access couchdb UI from browser applying `localhost:15984` or `http://192.168.59.3:15984/_utils/#database/myc1/_find` replace ipaddress with your machine ip address.

## Run Node end-to-end.js program:

Comment out the command variable (execution command) `command: sh -c 'sleep 5; ./channeltest.sh'` from CLI container in docker-compose file or modify `channeltest_node.sh` script to perform create, Join and deploy channels. Once the network is ready with the above approach, switch back to hyperledger directory and clone fabric-sdk-node repository to run end-to-end.js program.

clone latest [fabric-sdk-node](https://github.com/hyperledger/fabric-sdk-node.git) repository.

from fabric-sdk-node directory, execute `node end-to-end.js` and look for the result. That's it for now..
