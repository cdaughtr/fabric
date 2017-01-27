#!/bin/sh
#rm results.txt
#rm log.txt
#create
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer channel create -c myc1 >>log.txt 2>&1
   grep "Serializing identity" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on CHANNEL CREATION" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL CHANNEL CREATION" >> results.txt

sleep 5
TOTAL_PEERS=3
i=0
while test $i -lt $TOTAL_PEERS
do
echo "###################################### Joining peer$i"
#join
#CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb$i:5984 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer$i:7051 peer channel join -b myc1.block >>log.txt 2>&1
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer$i:7051 peer channel join -b myc1.block >>log.txt 2>&1
echo '-------------------------------------------------'
#cat log.txt
echo '-------------------------------------------------'
grep "Join Result: " log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on JOIN CHANNEL" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL JOIN CHANNEL" >> results.txt
echo "SUCCESSFUL JOIN CHANNEL"
i=$((i+1))
sleep 10
done

echo "Peer0 , Peer1 and Peer2 are added to the channel myc1"
sleep 10

#Deploy

echo "#deploy myc1 on peer0"

CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode deploy -C myc1 -n madhu -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}' >>log.txt 2>&1
#cat log.txt
echo '---------------------------------------------'
grep "openKeyStore" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on DEPLOY CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL DEPLOY CHAINCODE" >> results.txt
echo "SUCCESSFUL DEPLOY CHAINCODE"

sleep 30
#invoke
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode invoke -C myc1 -n madhu -c '{"Args":["invoke","a","b","10"]}' >>log.txt 2>&1
   grep "status:200" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on INVOKE CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL INVOKE CHAINCODE" >> results.txt
echo "SUCCESSFUL INVOKE ON PEER0"

#cat log.txt
sleep 15
echo "#################################### Query on peer0"
#query
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode query -C myc1 -n madhu -c '{"Args":["query","a"]}' >>log.txt 2>&1
   grep "Query Result peer: 90" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on QUERY CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL QUERY CHAINCODE on Peer0" >> results.txt
echo "SUCCESSFUL QUERY CHAINCODE on PEER0"
#cat results.txt
echo "THE TEST PASSED." >> results.txt
exit 0
