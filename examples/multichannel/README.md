#Fabric Multichannel Join functionality test steps:

Create directory Structure as mentioned in the multichannel directory

Execute below command on examples/multichannel directory from fabric repository. This executes multichain container and starts setenv.sh to fetch the latest ccenv tag and update docker-compose file

run `docker-compose -f docker-compose-channel.yml run -d multichain` 

run `docker-compose -f docker-compose-channel.yml up -d`
Execute above command to spinup 3 peer, 1 orderer (solo) and ca containers. Now the fabric network is ready.. Execute below commands in CLI container.

`docker exec -it cli sh`

now follow below commands to create channel, Join channel and submit deploy, invoke and query on any peer after joining channel on all peers.

### Create Channel
`CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer channel create -c myc1`
### Join Channel on peer0
`CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer0:7051 peer channel join -b myc1.block`
#### Deploy on Peer0
`CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode deploy -C myc1 -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}'`
####Invoke on Peer0
`CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode invoke -C myc1 -n mycc -c '{"Args":["invoke","a","b","10"]}'`
####Query on peer0
`CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode query -C myc1 -n mycc -c '{"Args":["query","a"]}'`
