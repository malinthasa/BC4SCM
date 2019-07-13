
'use strict';

const { Contract } = require('fabric-contract-api');

class SCMLogic extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const orders = [
            {
                id: 'BR0',
                batchno: '#12',
                type: 'tp01',
                date: '24062019',
            },
            {
                id: 'BR1',
                batchno: '#13',
                type: 'tp004',
                date: '18052004',
            }
        ];

        for (let i = 0; i < orders.length; i++) {
            orders[i].docType = 'bearing';
            await ctx.stub.putState('BR' + i, Buffer.from(JSON.stringify(orders[i])));
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

    async addPrivateOrder(ctx, collectionName, productId,  id ,batchno, type, date) {
        console.info('============= START : Create Product ===========');

        const order = {
            id,
            docType: 'bearing',
            batchno,
            type,
            date,
        };

        await ctx.stub.putPrivateData(collectionName, productId, Buffer.from(JSON.stringify(order)));
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

    async updatePrivateOrder(ctx, collectionName, productNumber, newOwner) {
        console.info('============= START : changeProductOwner ===========');

        const productAsBytes = await ctx.stub.getPrivateData(collectionName, productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        const order = JSON.parse(productAsBytes.toString());
        product.owner = newOwner;

        await ctx.stub.putPrivateData(collectionName, productId, Buffer.from(JSON.stringify(order)));

        console.info('============= END : changeProductOwner ===========');
    }

}

module.exports = SCMLogic;
