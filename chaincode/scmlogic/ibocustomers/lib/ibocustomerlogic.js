'use strict';

const { Contract } = require('fabric-contract-api');

class SCMLogic extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const products = [
            {
                productID: 'IBO0000',
                serialNo: '7676',
                date: '2019/07/13',
                status: 'Sample only.',
                owner: "IBO",
                decCertID: "",
                type: "bearing",
                certificateOfCompliance:"sample product"
            }
        ];

        for (let i = 0; i < products.length; i++) {
            await ctx.stub.putState(products[i].productID, Buffer.from(JSON.stringify(products[i])));
            console.info('Added <--> ', products[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

   // Function to get the product providing product ID
    async queryProduct(ctx, productId) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productId} does not exist`);
        }
        console.log(productAsBytes.toString());
        return productAsBytes.toString();
    }

    // Function to get the history of a product providing product ID
    async getProductHistory(ctx, productId) {
        const productAsBytes = await ctx.stub.getHistoryForKey(productId);
        let allResults = [];
        while (true) {
          let res = await productAsBytes.next();

          if (res.value && res.value.value.toString()) {
            let jsonRes = {};
            console.log(res.value.value.toString('utf8'));

            if (true && true === true) {
              jsonRes.TxId = res.value.tx_id;
              jsonRes.Timestamp = res.value.timestamp;
              jsonRes.IsDelete = res.value.is_delete.toString();
              try {
                jsonRes.Value = JSON.parse(res.value.value.toString('utf8'));
              } catch (err) {
                console.log(err);
                jsonRes.Value = res.value.value.toString('utf8');
              }
            } else {
              jsonRes.Key = res.value.key;
              try {
                jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
              } catch (err) {
                console.log(err);
                jsonRes.Record = res.value.value.toString('utf8');
              }
            }
            allResults.push(jsonRes);
          }
          if (res.done) {
            console.log('end of data');
            await productAsBytes.close();
            console.info(allResults);
            return allResults;
          }
        }

    }

    // Function to register given product
    async registerProduct(ctx, productId ,date, type) {

        // IBO is responsible for creating products.
        // So the status of the product is set to "Process Initiated' and the owner to 'IBO'
        const product = {
          productID: productId,
          serialNo: '',
          date: date,
          status: 'Process Initiated',
          owner: "IBO",
          decCertID: "",
          type: type
        };

        await ctx.stub.putState(product.productID, Buffer.from(JSON.stringify(product)));
    }

    // Function to change the owner of a given product
    async changeProductOwner(ctx, productId, newOwner, date) {

        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.owner = newOwner;
        product.date = date;
        product.status = "Owner changed to "+ newOwner

        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
    }

    //  Function  to change the current status of the product
    async changeProductStatus(ctx, productId, status, date) {

        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.status = status;
        product.date = date;

        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
    }

}

module.exports = SCMLogic;
