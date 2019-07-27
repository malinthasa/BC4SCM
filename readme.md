## **A prototype of an anti-counterfeiting blockchain for IBO GmbH.**


#
##### Project Description

This solution provides different functions to different parties. Main users of the system
are IBO, suppliers, retailers, 3PL and customers. IBO will have the ability to register
new products, query for product details, store and retrieve important documents
which will help them to have a more efficient and transparent business process.

     
#        
##### Prerequisites

1. Docker and Docker Compose

        Docker Docker version 17.06.2-ce or greater is required.
    
2. Go Programming Language
    
        Go version 1.11.x is required.
    
3. Node.js Runtime and NPM

        Node.js - version 8.x
        npm version 5.6.0

# 
##### Installation instructions

Installations process consists of two main tasks

1. Starting up Docker based Hyperledger Fabric Blockchain network as the backend
    
        1. Goto {root_folder}/network folder
        2. Run startFabric.sh shell script using ./startFabric.sh command
        
        Warning : This script cleans existing environement before startup the 
                  new environment
                  
        2019-07-27 20:14:11.252 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [b3abb3490c378c7254e42d8a1c2d83518bb44f1a5bb0fccf6c49045666b4ceb2] committed with status (VALID) at peer0.ibo.bc4scm.de:7051
        2019-07-27 20:14:11.256 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [b3abb3490c378c7254e42d8a1c2d83518bb44f1a5bb0fccf6c49045666b4ceb2] committed with status (VALID) at peer0.suppliera.bc4scm.de:13051
        2019-07-27 20:14:11.268 UTC [chaincodeCmd] ClientWait -> INFO 003 txid [b3abb3490c378c7254e42d8a1c2d83518bb44f1a5bb0fccf6c49045666b4ceb2] committed with status (VALID) at peer0.supplierb.bc4scm.de:15051
        2019-07-27 20:14:11.269 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 004 Chaincode invoke successful. result: status:200 
        + set +x

2. Installing and starting up frontend for each organization


After-Installation



# 
##### How to use the frontend

Please watch the video inside BC4SCM/demo folder

Steps

1. Add new product by IBO - Here we are creating a product ID **IBO0100**
2. Add new supply order by IBO to SupplierA - Here we refer the same product ID
3. Supplier check the order. Here Supplier can see IBO has already agreed for the order details. But the supplier wants to make change in the product description. The supplier makes that change and updates the order.
4. Now IBO view the change again and propose another change.
5. SupplierA view the order and propose another change.
6. IBO view the order and agree the change made by the supplier
7. SupplierA view the order summary and verify that IBO has agreed for the changes and start progress on the order. Here you change the status of the product to "Started working"
8. IBO can always check the status of the order until it is completed. 
9. After some time, the supplier marks the status of the order as "Completed"
 and inform IBO the status.
10. Then IBO start working on the product, manufacture it.
11. IBO is ready to sell product to a retailer called RetailerA.
12. RetailerA sells the product with id IBO0100 to ebd customer
13. Customer verifies the authenticity of the product and the history of the product.

# 
##### Architecture of the system

     Root Project Folder BC4SCM
     
    ├── chaincode - {Includes the chaincodes of separate Organizations}
    ├── demo      - {Includes the vedio of the demo}
    ├── frontend  - {Includes front end code for each Organization}
    ├── network   - {Includes Hyperledger network preparation code}
    └── readme.md

# 
##### Assumptions for the development

# 
##### Known bugs or errors