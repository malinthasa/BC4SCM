module.exports = {
	addProductDetails: async function () {
		return new Promise(async(resolve, reject) => {
			try {
				let user = 'user4';
				// Create a new file system based wallet for managing identities.
				const walletPath = path.join(process.cwd(), 'wallet');
				const wallet = new FileSystemWallet(walletPath);
				console.log(`Wallet path: ${walletPath}`);

				// Check to see if we've already enrolled the user.
				const userExists = await wallet.exists(user);
				if (!userExists) {
					console.log('An identity for the user ' + user + ' does not exist in the wallet');
					console.log('Run the registerUser.js application before retrying');
					return;
				}

				// Create a new gateway for connecting to our peer node.
				const gateway = new Gateway();

				await gateway.connect(ccpPath, { wallet, identity: user, discovery: { enabled: true, asLocalhost: true } });


				// Get the network (channel) our contract is deployed to.
				const network = await gateway.getNetwork('ibosupplierchannel');

				// Get the contract from the network.
				const contract = network.getContract('scmsupplierlogic');

				// Evaluate the specified transaction.
				// queryCar transaction - requires 1 argument, ex: ('queryCar', 'CAR4')
				// queryAllCars transaction - requires no arguments, ex: ('queryAllCars')
				// const result = await contract.evaluateTransaction('queryAllProducts');

			  await contract.submitTransaction('createPrivateProduct', 'collectionIBOSupplierA','BR66','BEAR102', 'malintha', 'bearing', '08072019');
				// console.log(result.toString())
				console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        await gateway.disconnect();

			} catch (error) {
				return reject('Failed to evaluate transaction');
			}
		})

	}
};
