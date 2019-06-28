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

## Create channel
echo "Creating channel1..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for ibo..."
updateAnchorPeers 0 1
echo "Updating anchor peers for retailer..."
updateAnchorPeers 0 2
echo "Updating anchor peers for supplier..."
updateAnchorPeers 0 3
echo "Updating anchor peers for logistic..."
updateAnchorPeers 0 4

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
