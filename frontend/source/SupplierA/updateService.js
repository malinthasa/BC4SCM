
'use strict';

const { FileSystemWallet, Gateway } = require('fabric-network');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..', '..',"..", 'network', 'connection-supplierA.json');

module.exports = {
	updateOrder: async function (orderId,des) {
		return new Promise(async(resolve, reject) => {
			try {

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = new FileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const userExists = await wallet.exists('userSupplierA');
        if (!userExists) {
            console.log('An identity for the user userIBO does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccpPath, { wallet, identity: 'userSupplierA', discovery: { enabled: true, asLocalhost: true } });
				// Get the network (channel) our contract is deployed to.
				const network = await gateway.getNetwork('ibosupplierchannel');

				// Get the contract from the network.
				const contract = network.getContract('scmsupplierlogic');
        console.log(des);
				console.log(orderId);
          await contract.submitTransaction('updatePrivateOrder', 'collectionIBOSupplierA',orderId,des);
        console.log(result);
				return resolve(result)

			} catch (error) {
				return reject('Failed to evaluate transaction');
			}
		})

	}
};
