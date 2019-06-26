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
CC_SRC_LANGUAGE=${1:-"go"}
CC_SRC_LANGUAGE=`echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:]`
if [ "$CC_SRC_LANGUAGE" = "go" -o "$CC_SRC_LANGUAGE" = "golang"  ]; then
	CC_RUNTIME_LANGUAGE=golang
	CC_SRC_PATH=github.com/chaincode/scmlogic/go
elif [ "$CC_SRC_LANGUAGE" = "javascript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/scmlogic/javascript
elif [ "$CC_SRC_LANGUAGE" = "typescript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH=/opt/gopath/src/github.com/chaincode/scmlogic/typescript
	echo Compiling TypeScript code into JavaScript ...
	pushd ../chaincode/scmlogic/typescript
	npm install
	npm run build
	popd
	echo Finished compiling TypeScript code into JavaScript
else
	echo The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script
	echo Supported chaincode languages are: go, javascript, and typescript
	exit 1
fi


# clean the keystore
rm -rf ./hfc-key-store

# launch network; create channel and join peer to channel
cd ../network
echo y | ./byfn.sh down
echo y | ./byfn.sh up -a -n -s couchdb

CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
IBO_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/ibo.bc4scm.de/users/Admin@ibo.bc4scm.de/msp
IBO_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/ibo.bc4scm.de/peers/peer0.ibo.bc4scm.de/tls/ca.crt
Retailer_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/retailer.bc4scm.de/users/Admin@retailer.bc4scm.de/msp
Retailer_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/retailer.bc4scm.de/peers/peer0.retailer.bc4scm.de/tls/ca.crt
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
    -n scmlogic \
    -v 1.0 \
    -p "$CC_SRC_PATH" \
    -l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.retailer.bc4scm.de"
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

echo "Instantiating smart contract on iboretailerchannel"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  cli \
  peer chaincode instantiate \
    -o orderer.bc4scm.de:7050 \
    -C iboretailerchannel \
    -n scmlogic \
    -l "$CC_RUNTIME_LANGUAGE" \
    -v 1.0 \
    -c '{"Args":[]}' \
    -P "AND('IBOMSP.member','RetailerMSP.member')" \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.ibo.bc4scm.de:7051 \
    --tlsRootCertFiles ${IBO_TLS_ROOTCERT_FILE}

echo "Waiting for instantiation request to be committed ..."
sleep 10

echo "Submitting initLedger transaction to smart contract on iboretailerchannel"
docker exec \
  -e CORE_PEER_LOCALMSPID=IBOMSP \
  -e CORE_PEER_MSPCONFIGPATH=${IBO_MSPCONFIGPATH} \
  cli \
  peer chaincode invoke \
    -o orderer.bc4scm.de:7050 \
    -C iboretailerchannel \
    -n scmlogic \
    -c '{"function":"initLedger","Args":[]}' \
    --waitForEvent \
    --tls \
    --cafile ${ORDERER_TLS_ROOTCERT_FILE} \
    --peerAddresses peer0.ibo.bc4scm.de:7051 \
    --peerAddresses peer0.retailer.bc4scm.de:9051 \
    --tlsRootCertFiles ${IBO_TLS_ROOTCERT_FILE} \
    --tlsRootCertFiles ${Retailer_TLS_ROOTCERT_FILE}
set +x

cat <<EOF

Total setup execution time : $(($(date +%s) - starttime)) secs ...

Next, use the FabCar applications to interact with the deployed FabCar contract.
The FabCar applications are available in multiple programming languages.
Follow the instructions for the programming language of your choice:

JavaScript:

  Start by changing into the "javascript" directory:
    cd javascript

  Next, install all required packages:
    npm install

  Then run the following applications to enroll the admin user, and register a new user
  called user1 which will be used by the other applications to interact with the deployed
  FabCar contract:
    node enrollAdmin
    node registerUser

  You can run the invoke application as follows. By default, the invoke application will
  create a new car, but you can update the application to submit other transactions:
    node invoke

  You can run the query application as follows. By default, the query application will
  return all cars, but you can update the application to evaluate other transactions:
    node query

TypeScript:

  Start by changing into the "typescript" directory:
    cd typescript

  Next, install all required packages:
    npm install

  Next, compile the TypeScript code into JavaScript:
    npm run build

  Then run the following applications to enroll the admin user, and register a new user
  called user1 which will be used by the other applications to interact with the deployed
  FabCar contract:
    node dist/enrollAdmin
    node dist/registerUser

  You can run the invoke application as follows. By default, the invoke application will
  create a new car, but you can update the application to submit other transactions:
    node dist/invoke

  You can run the query application as follows. By default, the query application will
  return all cars, but you can update the application to evaluate other transactions:
    node dist/query

EOF
