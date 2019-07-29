#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

export MSYS_NO_PATHCONV=1
starttime=$(date +%s)

CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/scmlogic/javascript
CC_SRC_PATH_SUPPLIER=/opt/gopath/src/github.com/chaincode/scmlogic/ibosuppliers
CC_SRC_PATH_RETAILER=/opt/gopath/src/github.com/chaincode/scmlogic/iboretailers
CC_SRC_PATH_LOGISTIC=/opt/gopath/src/github.com/chaincode/scmlogic/ibologistics
CC_SRC_PATH_CUSTOMER=/opt/gopath/src/github.com/chaincode/scmlogic/ibocustomers


# launch network; create channel and join peer to channel
echo y | ./scmnetwork.sh down
echo y | ./scmnetwork.sh up -a -n -s couchdb

# specifying certificate locations
CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
IBO_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/ibo.bc4scm.de/users/Admin@ibo.bc4scm.de/msp
IBO_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/ibo.bc4scm.de/peers/peer0.ibo.bc4scm.de/tls/ca.crt
Retailer_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/retailer.bc4scm.de/users/Admin@retailer.bc4scm.de/msp
Retailer_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/retailer.bc4scm.de/peers/peer0.retailer.bc4scm.de/tls/ca.crt
SupplierA_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/suppliera.bc4scm.de/users/Admin@suppliera.bc4scm.de/msp
SupplierA_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/suppliera.bc4scm.de/peers/peer0.suppliera.bc4scm.de/tls/ca.crt
SupplierB_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/supplierb.bc4scm.de/users/Admin@supplierb.bc4scm.de/msp
SupplierB_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/supplierb.bc4scm.de/peers/peer0.supplierb.bc4scm.de/tls/ca.crt
Customer_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/customer.bc4scm.de/users/Admin@customer.bc4scm.de/msp
Customer_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/customer.bc4scm.de/peers/peer0.customer.bc4scm.de/tls/ca.crt
ORDERER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/ordererOrganizations/bc4scm.de/orderers/orderer.bc4scm.de/msp/tlscacerts/tlsca.bc4scm.de-cert.pem
set -x


echo "Installing smart contract on peer0.ibo.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_ADDRESS=peer0.ibo.bc4scm.de:7051 \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${IBO_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmsupplierlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH_SUPPLIER" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.ibo.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_ADDRESS=peer0.ibo.bc4scm.de:7051 \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${IBO_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmcustomerlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH_CUSTOMER" \
    -l "$CC_RUNTIME_LANGUAGE"

# Notice : This chaincode is installed in Private data collections
# Please find the PDC configurations in {root_folder}/chaincode/ibosuppliers/collection_config.json location
echo "Installing smart contract on peer0.supplierA.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=SupplierAMSP \
  -e CORE_PEER_ADDRESS=peer0.suppliera.bc4scm.de:13051 \
  -e CORE_PEER_MSPCONFIGPATH=${SupplierA_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${SupplierA_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmsupplierlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH_SUPPLIER" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.supplierB.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=SupplierBMSP \
  -e CORE_PEER_ADDRESS=peer0.supplierb.bc4scm.de:15051 \
  -e CORE_PEER_MSPCONFIGPATH=${SupplierB_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${SupplierB_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmsupplierlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH_SUPPLIER" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.customer.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=CustomerMSP \
  -e CORE_PEER_ADDRESS=peer0.customer.bc4scm.de:19051 \
  -e CORE_PEER_MSPCONFIGPATH=${Customer_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${Customer_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmcustomerlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH_CUSTOMER" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.retailer.bc4scm.de"
docker exec \
  -e CORE_PEER_LOCALMSPID=RetailerMSP \
  -e CORE_PEER_ADDRESS=peer0.retailer.bc4scm.de:9051 \
  -e CORE_PEER_MSPCONFIGPATH=${Retailer_MSPCONFIGPATH} \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${Retailer_TLS_ROOTCERT_FILE} \
  cli \
  peer chaincode install \
    -n scmcustomerlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH_RETAILER" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Instantiating smart contract on ibo"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  cli \
  peer chaincode instantiate \
    -o orderer.bc4scm.de:7050 \
    -C ibosupplierchannel \
    -n scmsupplierlogic \
    -l "$CC_RUNTIME_LANGUAGE" \
    -v 1.0 \
    -c '{"Args":[]}' \
    -P "OR('IBOMSP.member', 'SupplierAMSP.member', 'SupplierBMSP.member')" \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.ibo.bc4scm.de:7051 \
    --tlsRootCertFiles ${IBO_TLS_ROOTCERT_FILE} \
    --collections-config ${CC_SRC_PATH_SUPPLIER}/collection_config.json

echo "Instantiating IBO customer smart contract on ibo"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  cli \
  peer chaincode instantiate \
    -o orderer.bc4scm.de:7050 \
    -C ibocustomerchannel \
    -n scmcustomerlogic \
    -l "$CC_RUNTIME_LANGUAGE" \
    -v 1.0 \
    -c '{"Args":[]}' \
    -P "OR('IBOMSP.member', 'RetailerMSP.member', 'CustomerMSP.member')" \
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
    -n scmsupplierlogic \
    -c '{"function":"initLedger","Args":[]}' \
    --waitForEvent \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.ibo.bc4scm.de:7051 \
    --peerAddresses peer0.suppliera.bc4scm.de:13051 \
    --peerAddresses peer0.supplierb.bc4scm.de:15051 \
    --tlsRootCertFiles ${IBO_TLS_ROOTCERT_FILE} \
    --tlsRootCertFiles ${SupplierA_TLS_ROOTCERT_FILE} \
    --tlsRootCertFiles ${SupplierB_TLS_ROOTCERT_FILE}
set +x
