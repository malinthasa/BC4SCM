/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { FileSystemWallet, Gateway, X509WalletMixin } = require('fabric-network');
const path = require('path');

const ccpPath = path.resolve(__dirname, '..', '..', "..","..", 'network', 'connection-ibo.json');

async function main() {
    try {

        let user = 'userIBO';
        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = new FileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const userExists = await wallet.exists(user);
        if (userExists) {
            console.log('An identity for the user "userIBO" already exists in the wallet');
            return;
        }
        console.log("========================User Not found===========================")

        // Check to see if we've already enrolled the admin user.
        const adminExists = await wallet.exists('admin');
        if (!adminExists) {
            console.log('An identity for the admin user "admin" does not exist in the wallet');
            console.log('Run the enrollAdmin.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
          console.log("========================Up to this point===========================")
        await gateway.connect(ccpPath, { wallet, identity: 'admin', discovery: { enabled: true, asLocalhost: true } });
        console.log("========================Up to this point1===========================")
        // Get the CA client object from the gateway for interacting with the CA.
        const ca = gateway.getClient().getCertificateAuthority();
        const adminIdentity = gateway.getCurrentIdentity();

        let affiliationService = ca.newAffiliationService();
        let registeredAffiliations = await affiliationService.getAll(adminIdentity);
             await affiliationService.create({
              name: 'ibo.department1',
              force: true}, adminIdentity);

      //  Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({ affiliation: 'ibo.department1', enrollmentID: user, role: 'client' }, adminIdentity);
        const enrollment = await ca.enroll({ enrollmentID: user, enrollmentSecret: secret });
        const userIdentity = X509WalletMixin.createIdentity('IBOMSP', enrollment.certificate, enrollment.key.toBytes());
        await wallet.import(user, userIdentity);

        console.log('Successfully registered and enrolled admin user '+ user +' and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to register user "userIBO": ${error}`);
        process.exit(1);
    }
}

main();
