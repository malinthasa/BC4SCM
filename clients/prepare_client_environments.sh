#!/usr/bin/env bash
cd Customer/source
npm install
if [ -d "wallet" ]; then rm -Rf wallet; fi
node enrollGenericAdmin.js
node registerGenericAffliation.js
node registerGenericUser.js

cd ../..
cd IBO/source
npm install
if [ -d "wallet" ]; then rm -Rf wallet; fi
node enrollGenericAdmin.js
node registerGenericAffliation.js
node registerGenericUser.js

cd ../..
cd SupplierA/source
npm install
if [ -d "wallet" ]; then rm -Rf wallet; fi
node enrollGenericAdmin.js
node registerGenericAffliation.js
node registerGenericUser.js

cd ../..
cd Retailer/source
npm install
if [ -d "wallet" ]; then rm -Rf wallet; fi
node enrollGenericAdmin.js
node registerGenericAffliation.js
node registerGenericUser.js
