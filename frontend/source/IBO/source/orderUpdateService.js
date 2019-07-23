
'use strict';

const { FileSystemWallet, Gateway } = require('fabric-network');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..', '..',"..", "..",'network', 'connection-ibo.json');

module.exports = {
	updateOrder: async function (oid, des, ibo, supplier) {
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

        const gateway = new Gateway();
        await gateway.connect(ccpPath, { wallet, identity: 'userIBO', discovery: { enabled: true, asLocalhost: true } });
				// Get the network (channel) our contract is deployed to.
				const network = await gateway.getNetwork('ibosupplierchannel');

				// Get the contract from the network.
				const contract = network.getContract('scmsupplierlogic');

				console.log("pppppppppppppppppppppppppppppp");
				console.log(ibo, supplier);

				const result = await contract.submitTransaction('updatePrivateOrder','collectionIBOSupplierA', oid, des, ibo, supplier);

				return;

			} catch (error) {
				return reject('Failed to evaluate transaction');
			}
		})
	}
};
