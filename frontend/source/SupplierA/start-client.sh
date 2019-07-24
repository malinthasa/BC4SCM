cd source/
if [ -d "wallet" ]; then rm -Rf wallet; fi
node enrollGenericAdmin.js
node registerGenericAffliation.js
node registerGenericUser.js
node supplierfrontend.js
