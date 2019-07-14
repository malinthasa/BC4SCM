
'use strict';

const { Contract } = require('fabric-contract-api');

class SCMLogic extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const products = [
            {
                productID: 'IBO0001',
                serialNo: '7676',
                date: '2019/07/13',
                status: 'ordered supply',
                owner: "IBO",
                decCertID: "",
                type: "bearing"
            }
        ];

        for (let i = 0; i < products.length; i++) {
            await ctx.stub.putState(products[i].productID, Buffer.from(JSON.stringify(products[i])));
            console.info('Added <--> ', products[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryPrivateProduct(ctx, collectionName, productId) {
        const productAsBytes = await ctx.stub.getPrivateData(collectionName, productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productId} does not exist`);
        }
        console.log(productAsBytes.toString());
        return productAsBytes.toString();
    }

    async queryProduct(ctx, productId) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productId} does not exist`);
        }
        console.log(productAsBytes.toString());
        return productAsBytes.toString();
    }

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

    async registerPrivateProduct(ctx, collectionName, productId,  id ,batchno, type, date) {
        console.info('============= START : Create Product ===========');

        const product = {
            id,
            docType: 'bearing',
            batchno,
            type,
            date,
        };

        await ctx.stub.putPrivateData(collectionName, productId, Buffer.from(JSON.stringify(product)));
        console.info('============= END : Created Private Product ===========');
    }


    async changeProductOwner(ctx, productNumber, newOwner) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getState(productNumber);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.owner = newOwner;

        await ctx.stub.putState(productNumber, Buffer.from(JSON.stringify(product)));
        console.info('============= END : changeProductOwner ===========');
    }

    async registerProduct(ctx, productId ,date, type) {
        console.info('============= START : Registering Product ===========');

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
        console.info('============= END : Created Product ===========');
    }

    async changeProductOwner(ctx, productId, newOwner) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.owner = newOwner;
        product.date = date;
        product.status = "Owner changed to "+ newOwner

        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.info('============= END : changeProductOwner ===========');
    }

    async changeProductStatus(ctx, productId, status, date) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.status = status;
        product.date = date;

        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        console.info('============= END : changeProductOwner ===========');
    }

}

module.exports = SCMLogic;
