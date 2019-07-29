
'use strict';

//call smart contract to add supplier order

const { FileSystemWallet, Gateway } = require('fabric-network');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..', "..", "..", 'network', 'connection-ibo.json');

module.exports = {
	registerOrder: async function (oid, pid, chash, rhash, shash, serial, desc, date) {
		return new Promise(async(resolve, reject) => {
			try {

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = new FileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const userExists = await wallet.exists('userIBO');
        if (!userExists) {
            console.log('An identity for the user userIBO does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccpPath, { wallet, identity: 'userIBO', discovery: { enabled: true, asLocalhost: true } });
				// Get the network (channel) our contract is deployed to.
				const network = await gateway.getNetwork('ibosupplierchannel');

				// Get the contract from the network.
				const contract = network.getContract('scmsupplierlogic');

        await contract.submitTransaction('addPrivateOrder',
        'collectionIBOSupplierA',oid,pid, chash, shash, rhash, serial,date,
         desc, 'supplierA', 'Placed Order');
        console.log('Transaction has been submitted');
				return;

			} catch (error) {
				return reject('Failed to evaluate transaction');
			}
		})
	}
};
