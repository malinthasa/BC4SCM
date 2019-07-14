
'use strict';

const { Contract } = require('fabric-contract-api');

class SCMLogic extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const orders = [
          {
              orderID: 'ORD0001',
              productID: 'IBO0001',
              CADHash: 'QmXJaC6CjKN7QBwvCNyHUP3y11KYWuMPRsG1RBqvc31TMh',
              specHash: 'QmXJuy6CjKN7QBwvCNyHUP3y11KYWuMPRsG1RBqvc31TMg',
              requirementHash: 'QmXJaC6CjKN7QBwvCNyHUP3y11KYWuMPRsG1RByuyu1TMg',
              serialNo: '7676',
              date: '2019/07/13',
              description: 'ordered supply',
              supplierID: "SupA",
              status: "created",
              IBOAgreed:false,
              SupplierAgreed:false
          }
        ];

        for (let i = 0; i < orders.length; i++) {
            await ctx.stub.putState(orders[i].orderID, Buffer.from(JSON.stringify(orders[i])));
            console.info('Added <--> ', orders[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryPrivateOrder(ctx, collectionName, productId) {
        const productAsBytes = await ctx.stub.getPrivateData(collectionName, productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productId} does not exist`);
        }
        console.log(productAsBytes.toString());
        return productAsBytes.toString();
    }

    async addPrivateOrder(ctx, collectionName, orderId, productId,  CADHash ,specHash,
      requirementHash, serialNo, date, description, supplierID, status) {
        console.info('============= START : Create Order ===========');

        const order = {
          orderID: orderId,
          productID: productId,
          CADHash: CADHash,
          specHash: specHash,
          requirementHash: requirementHash,
          serialNo: serialNo,
          date: date,
          description: description,
          supplierID: supplierID,
          status: status,
          IBOAgreed:false,
          SupplierAgreed:false
        };

        await ctx.stub.putPrivateData(collectionName, orderId, Buffer.from(JSON.stringify(order)));
        console.info('============= END : Created Private Order ===========');
    }


    async queryAllPrivateOrders(ctx,collectionName) {
        const startKey = '';
        const endKey = '';

        var {iterator} = await ctx.stub.getPrivateDataByRange(collectionName, startKey, endKey);

        const allResults = [];
        while (true) {
            const res = await iterator.next();

            if (res.value && res.value.value.toString()) {
                console.log(res.value.value.toString('utf8'));

                const Key = res.value.key;
                let Record;
                try {
                    Record = JSON.parse(res.value.value.toString('utf8'));
                } catch (err) {
                    console.log(err);
                    Record = res.value.value.toString('utf8');
                }
                allResults.push({ Key, Record });
            }
            if (res.done) {
                console.log('end of data');
                await iterator.close();
                console.info(allResults);
                return JSON.stringify(allResults);
            }
        }
    }

    async changeProductOwner(ctx, productNumber, newOwner) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getPrivateData(collectionName, productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.owner = newOwner;

        await ctx.stub.putState(productNumber, Buffer.from(JSON.stringify(product)));
        console.info('============= END : changeProductOwner ===========');
    }

    async updatePrivateOrderIBOAgreed(ctx, collectionName, orderId, IBOAgreed) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getPrivateData(collectionName, orderId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const order = JSON.parse(productAsBytes.toString());
        order.IBOAgreed = IBOAgreed;

        await ctx.stub.putPrivateData(collectionName, orderId, Buffer.from(JSON.stringify(order)));

        console.info('============= END : changeProductOwner ===========');
    }

    async updatePrivateOrderSupplierAgreed(ctx, collectionName, orderId, SupplierAgreed) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getPrivateData(collectionName, orderId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const order = JSON.parse(productAsBytes.toString());
        order.SupplierAgreed = SupplierAgreed;

        await ctx.stub.putPrivateData(collectionName, orderId, Buffer.from(JSON.stringify(order)));

        console.info('============= END : changeProductOwner ===========');
    }

    async updatePrivateOrderStatus(ctx, collectionName, orderId, status) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getPrivateData(collectionName, orderId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const order = JSON.parse(productAsBytes.toString());
        order.status = status;

        await ctx.stub.putPrivateData(collectionName, orderId, Buffer.from(JSON.stringify(order)));

        console.info('============= END : changeProductOwner ===========');
    }

    async updatePrivateOrder(ctx, collectionName, orderId, description) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getPrivateData(collectionName, orderId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const order = JSON.parse(productAsBytes.toString());
        order.description = description;
        

        await ctx.stub.putPrivateData(collectionName, orderId, Buffer.from(JSON.stringify(order)));

        console.info('============= END : changeOrder===========');
    }

}

module.exports = SCMLogic;
