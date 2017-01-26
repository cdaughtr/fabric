#!/bin/sh
rm results.txt
rm log.txt
echo "#create channel on orderer"
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer channel create -c myc1 >>log.txt 2>&1
   grep "Serializing identity" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on CHANNEL CREATION" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL CHANNEL CREATION" >> results.txt

sleep 5

echo "#join myc1 channel on peer0"
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer0:7051 peer channel join -b myc1.block >>log.txt 2>&1
echo '-------------------------------------------------'
#cat log.txt
echo '-------------------------------------------------'
grep "Join Result: " log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on JOIN CHANNEL" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL JOIN CHANNEL" >> results.txt

sleep 10
#done
echo "# join myc1 channel on peer1"
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer1:7051 peer channel join -b myc1.block >>log.txt 2>&1
echo '-------------------------------------------------'
#cat log.txt
echo '-------------------------------------------------'
grep "Join Result: " log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on JOIN CHANNEL" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL JOIN CHANNEL" >> results.txt

sleep 10
echo "# join myc1 channel on peer2"
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer2:7051 peer channel join -b myc1.block >>log.txt 2>&1
echo '-------------------------------------------------'
#cat log.txt
echo '-------------------------------------------------'
grep "Join Result: " log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on JOIN CHANNEL" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL JOIN CHANNEL" >> results.txt

sleep 10

echo "#deploy myc1 on peer0"
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode deploy -C myc1 -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}' >>log.txt 2>&1
   grep "openKeyStore" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on DEPLOY CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL DEPLOY CHAINCODE" >> results.txt

sleep 10

##
echo "#invoke on peer0"
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode invoke -C myc1 -n mycc -c '{"Args":["invoke","a","b","10"]}' >>log.txt 2>&1
   grep "status:200" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on INVOKE CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL INVOKE CHAINCODE" >> results.txt

sleep 10
echo "query on channel myc1 on peer0"
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode query -C myc1 -n mycc -c '{"Args":["query","a"]}' >>log.txt 2>&1
   grep "Query Result: 90" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on QUERY CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL QUERY CHAINCODE" >> results.txt

echo "query on channel myc1 on peer1"
CORE_PEER_ADDRESS=peer1:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode query -C myc1 -n mycc -c '{"Args":["query","a"]}' >>log.txt 2>&1
   grep "Query Result: 90" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on QUERY CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL QUERY CHAINCODE" >> results.txt
echo "THE TEST PASSED." >> results.txt

echo "query on channel myc1 on peer2"
CORE_PEER_ADDRESS=peer2:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer chaincode query -C myc1 -n mycc -c '{"Args":["query","a"]}' >>log.txt 2>&1
   grep "Query Result: 90" log.txt
   if [ $? -ne 0 ]; then
      echo "ERROR on QUERY CHAINCODE" >> results.txt
      exit 1
   fi
echo "SUCCESSFUL QUERY CHAINCODE" >> results.txt
echo "THE TEST PASSED." >> results.txt
exit 0

