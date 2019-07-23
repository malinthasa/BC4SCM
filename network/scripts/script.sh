#!/bin/bash

CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
NO_CHAINCODE="$6"
: ${CHANNEL_NAME:="iboretailerchannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="node"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
: ${NO_CHAINCODE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10
CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/scmlogic/javascript"

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

createSpecificChannel() {
	PEER=$1
  ORG=$2
  CHANNEL_NAME=$3
	CHANNEL_TX_NAME=$4
	setGlobals $PEER $ORG

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_TX_NAME --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
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
		sleep 3
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
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

updateSpecificAnchorPeers() {
  PEER=$1
  ORG=$2
	CHANNEL_NAME=$3
	CORE_PEER_SPECIFIC_MSPID=$4
  setGlobals $PEER $ORG

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_SPECIFIC_MSPID}.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.bc4scm.de:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_SPECIFIC_MSPID}.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_SPECIFIC_MSPID' on channel '$CHANNEL_NAME' ===================== "
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
echo "Creating channel1..."
createChannel

createSpecificChannel 0 1 ibosupplierchannel channelIBOSupplier.tx
createSpecificChannel 0 1 ibocustomerchannel channelIBOCustomer.tx


joinSpecificChannelWithRetry 0 1 ibosupplierchannel
joinSpecificChannelWithRetry 0 3 ibosupplierchannel
joinSpecificChannelWithRetry 1 3 ibosupplierchannel
joinSpecificChannelWithRetry 0 4 ibosupplierchannel
joinSpecificChannelWithRetry 0 5 ibosupplierchannel
joinSpecificChannelWithRetry 1 4 ibosupplierchannel
joinSpecificChannelWithRetry 1 5 ibosupplierchannel

echo "Joining IBO to IBOCustomerChannel"
joinSpecificChannelWithRetry 0 1 ibocustomerchannel
echo "Joining Customer peer0 to IBOCustomerChannel"
joinSpecificChannelWithRetry 0 7 ibocustomerchannel
echo "Joining Customer peer1 to IBOCustomerChannel"
joinSpecificChannelWithRetry 1 7 ibocustomerchannel
echo "Joining Retailer peer0 to IBOCustomerChannel"
joinSpecificChannelWithRetry 0 2 ibocustomerchannel
echo "Joining Retailer peer1 to IBOCustomerChannel"
joinSpecificChannelWithRetry 1 2 ibocustomerchannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
# joinChannel
#
## Set the anchor peers for each org in the channel
echo "Updating anchor peers for ibo..."
updateSpecificAnchorPeers 0 1 ibosupplierchannel IBOMSPanchors_IBOSupplierChannel

# updateSpecificAnchorPeers 0 3 ibosupplierchannel SupplierMSPanchors_IBOSupplierChannel
updateSpecificAnchorPeers 0 4 ibosupplierchannel SupplierAMSPanchors_IBOSupplierChannel
updateSpecificAnchorPeers 0 5 ibosupplierchannel SupplierBMSPanchors_IBOSupplierChannel

updateSpecificAnchorPeers 0 1 ibocustomerchannel IBOMSPanchors_IBOCustomerChannel
updateSpecificAnchorPeers 0 2 ibocustomerchannel RetailerMSPanchors_IBOCustomerChannel
updateSpecificAnchorPeers 0 7 ibocustomerchannel CustomerMSPanchors_IBOCustomerChannel



#
if [ "${NO_CHAINCODE}" != "true" ]; then
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
# 	## Install chaincode on peer0.ibo and peer0.retailer
 	echo "Installing chaincode on peer0.ibo..."
 	installChaincodeOnSpecificNode 0 1
fi

echo "========= Network execution completed =========== "
echo

exit 0
