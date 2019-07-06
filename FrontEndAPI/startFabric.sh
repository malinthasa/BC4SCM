#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)

CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/scmlogic/javascript

# clean the keystore
rm -rf ./hfc-key-store

# launch network; create channel and join peer to channel
cd ../network
echo y | ./scmnetwork.sh down
echo y | ./scmnetwork.sh up -a -n -s couchdb

CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
IBO_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/ibo.bc4scm.de/users/Admin@ibo.bc4scm.de/msp
IBO_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/ibo.bc4scm.de/peers/peer0.ibo.bc4scm.de/tls/ca.crt
Retailer_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/retailer.bc4scm.de/users/Admin@retailer.bc4scm.de/msp
Retailer_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/retailer.bc4scm.de/peers/peer0.retailer.bc4scm.de/tls/ca.crt
Supplier_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/supplier.bc4scm.de/users/Admin@supplier.bc4scm.de/msp
Supplier_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/supplier.bc4scm.de/peers/peer0.supplier.bc4scm.de/tls/ca.crt
ORDERER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/ordererOrganizations/bc4scm.de/orderers/orderer.bc4scm.de/msp/tlscacerts/tlsca.bc4scm.de-cert.pem
set -x
#
echo "Installing smart contract on peer0.ibo.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_ADDRESS=peer0.ibo.bc4scm.de:7051 \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${IBO_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH" \
    -l "$CC_RUNTIME_LANGUAGE"


#
echo "Installing smart contract on peer0.supplier.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=SupplierMSP \
  -e CORE_PEER_ADDRESS=peer0.supplier.bc4scm.de:11051 \
  -e CORE_PEER_MSPCONFIGPATH=${Supplier_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${Supplier_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.supplier.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=RetailerMSP \
  -e CORE_PEER_ADDRESS=peer0.retailer.bc4scm.de:9051 \
  -e CORE_PEER_MSPCONFIGPATH=${Retailer_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${Retailer_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH" \
    -l "$CC_RUNTIME_LANGUAGE"
#
echo "Instantiating smart contract on ibo"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  cli \
  peer chaincode instantiate \
    -o orderer.bc4scm.de:7050 \
    -C ibosupplierchannel \
    -n scmlogic \
    -l "$CC_RUNTIME_LANGUAGE" \
    -v 1.0 \
    -c '{"Args":[]}' \
    -P "OR('IBOMSP.member','SupplierMSP.member')" \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.ibo.bc4scm.de:7051 \
    --tlsRootCertFiles ${IBO_TLS_ROOTCERT_FILE} \


echo "Waiting for instantiation request to be committed ..."
sleep 10

#
echo "Submitting initLedger transaction to smart contract on iboretailerchannel"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  cli \
  peer chaincode invoke \
    -o orderer.bc4scm.de:7050 \
    -C ibosupplierchannel \
    -n scmlogic \
    -c '{"function":"initLedger","Args":[]}' \
    --waitForEvent \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.ibo.bc4scm.de:7051 \
    --peerAddresses peer0.supplier.bc4scm.de:11051 \
    --tlsRootCertFiles ${IBO_TLS_ROOTCERT_FILE} \
    --tlsRootCertFiles ${Supplier_TLS_ROOTCERT_FILE}
set +x
