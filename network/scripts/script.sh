#!/bin/bash

CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
NO_CHAINCODE="$6"
: ${CHANNEL_NAME:="iboretailerchannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
: ${NO_CHAINCODE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

if [ "$LANGUAGE" = "java" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/java/"
fi

echo "Channel name : "$CHANNEL_NAME
$CHANNEL_IBO_SUPPLIER_NAME = "ibosupplierchannel"

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

createIBOSupplierChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.bc4scm.de:7050 -c $CHANNEL_IBO_SUPPLIER_NAME -f ./channel-artifacts/channelIBOSupplier.tx -channelID $CHANNEL_IBO_SUPPLIER_NAME
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.bc4scm.de:7050 -c $CHANNEL_IBO_SUPPLIER_NAME -f ./channel-artifacts/channelIBOSupplier.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -channelID $CHANNEL_IBO_SUPPLIER_NAME
		res=$?
				set +x
	fi
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}


joinChannel () {
	for org in 1 2 3; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
}

joinSpecificChannel () {
	for org in 1 2 3; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
}

joinSpecificChannelWithRetry() {
  PEER=$1
  ORG=$2
  CHANNEL_NAME=$3
  setGlobals $PEER $ORG

  set -x
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

updateSpecificAnchorPeers() {
  PEER=$1
  ORG=$2
	CHANNEL_NAME=$3
  setGlobals $PEER $ORG

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
  sleep $DELAY
  echo
}

installChaincodeOnSpecificNode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}
  set -x
  peer chaincode install -n mycc -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH} >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
  echo
}

## Create channel
echo "Creating channels..."
createChannel
createIBOSupplierChannel
## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel
joinSpecificChannelWithRetry 0 1 "ibosupplierchannel"
# TODO write seperate code each channel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for ibo..."
updateAnchorPeers 0 1
echo "Updating anchor peers for retailer..."
updateAnchorPeers 0 2
echo "Updating anchor peers for supplier..."
updateAnchorPeers 0 3
echo "Updating anchor peers for logistic..."
updateAnchorPeers 0 4

# Updating anchor peers for a given channel
updateSpecificAnchorPeers 0 1 "ibosupplierchannel"
updateSpecificAnchorPeers 0 3 "ibosupplierchannel"

if [ "${NO_CHAINCODE}" != "true" ]; then

	## Install chaincode on peer0.ibo and peer0.retailer
	echo "Installing chaincode on peer0.ibo..."
	installChaincode 0 1
	echo "Install chaincode on peer0.retailer..."
	installChaincode 0 2
	echo "Install chaincode on peer0.supplier..."
	installChaincode 0 3
	echo "Install chaincode on peer0.logistic..."
	installChaincode 0 4

	# TODO Installing chain code on each node
	installChaincodeOnSpecificNode 0 1

	# Instantiate chaincode on peer0.retailer
	echo "Instantiating chaincode on peer0.retailer..."
	instantiateChaincode 0 2

	# Query chaincode on peer0.ibo
	echo "Querying chaincode on peer0.ibo..."
	chaincodeQuery 0 1 100

	# Invoke chaincode on peer0.ibo and peer0.retailer
	echo "Sending invoke transaction on peer0.ibo peer0.retailer..."
	chaincodeInvoke 0 1 0 2

	## Install chaincode on peer1.retailer
	echo "Installing chaincode on peer1.retailer..."
	installChaincode 1 2

	# Query on chaincode on peer1.retailer, check if the result is 90
	echo "Querying chaincode on peer1.retailer..."
	chaincodeQuery 1 2 90

fi

echo "========= Network execution completed =========== "
echo

exit 0
