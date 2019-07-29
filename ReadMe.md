## **A prototype of an anti-counterfeiting blockchain for IBO GmbH.**


#
### Project Description

This solution provides different functions to different parties. Primary users of the system are IBO, suppliers, retailers, 3PL, and customers. IBO will have the ability to register new products, query for product details, store and retrieve essential documents which help them to have a more efficient and transparent business process.

     
#        
### Prerequisites

1. Docker and Docker Compose

        Docker Docker version 17.06.2-ce or greater is required.
    
2. Go Programming Language
    
        Go version 1.11.x is required.
    
3. Node.js Runtime and NPM

        Node.js - version 8.x
        npm version 5.6.0

# 
### Installation instructions

Installations process consists of two main tasks

1. Starting up Docker based Hyperledger Fabric Blockchain network as the backend

       Whats happens here
        
       This step configures and starts up the blockchain infrastructure. First, it removes existing infrastructure, 
       including all docker containers and artifacts. Then it generates the required certificate for all participants in
       the network. Once the certificate generation is completed, it docker containers for the requested network and 
       tart up a running environment. Once the environment is ready, it creates channels, joins peers to corresponding
       channels, and finally install chain codes on each organization peers.
        

         Steps
    
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

        What happens here
        
        This steps prepares the clients to interact with the backend blockchain. It creates required certificates for 
        each client and store them locally. Then it installes required npm dependencie for each client application.
        
        
        Steps

        1. Goto {root_folder}/clients folder.
        2. Run prepare_client_environments.sh shell script by ./prepare_client_environments.sh command


**Note**: This is an onetime operation. Once you have installed all components, you can use the application by using the 
          instructions in "Run Frontend Application" section  

# 
### Run Frontend Application


**Note** : This prototype has been implemented for IBO, SupplierA, Retailer & Customer clients

There are separate clients for each organization. These clients are inside {root_folder}/clients location.

    ├── Customer
    ├── IBO
    ├── Logistic
    ├── prepare_client_environments.sh
    ├── Retailer
    ├── SupplierA
    └── SupplierB

1. Run IBO Frontend Application

          1. Goto {root_folder}/clients/IBO folder
          2. Run "start-client.sh" using ./start-client.sh command
    
    This script will run the IBO frontend application client on 8081 port. You can access this application from 
    http://localhost:8081/ address
    
2. Run SupplierA Frontend Application

        1. Goto {root_folder}/clients/SupplierA folder
        2. Run "start-client.sh" using ./start-client.sh command
    
    This script will run the SupplierA frontend application client on 8082 port. You can access this application from 
    http://localhost:8082/ address
    
3. Run Retailer Frontend Application

        1. Goto {root_folder}/clients/Retailer folder
        2. Run "start-client.sh" using ./start-client.sh command
         
   This script will run the Retailer frontend application client on 8084 port. You can access this application from 
   http://localhost:8084/ address
   
4. Run Customer Frontend Application

        1. Goto {root_folder}/clients/Customer folder
        2. Run "start-client.sh" using ./start-client.sh command
    
    This script will run the Customer frontend application client on 8083 port. You can access this application from 
    http://localhost:8083/ address
    
5. Run IPFS client to get hases of the documents

        1. Goto {root_fodler}/utils/IPFS_Client folder
        2. Run ipfs.html in your browser as local web page
        

**Note** : If you want to restart the application, you can re-run the instructions in "Run Frontend Application" section
# 
### How to use the frontend

Please watch the video inside BC4SCM/demo folder.

Demo scenario : 
                
    We start with a customer placing an order to IBO for some specific product. Here IBO creates a new product according 
    to customer's specifications. There, IBO provides an identification number for the product. This identification number 
    is used throughout the scenario to identify the product. Next IBO contacts a supplier (here SupplierA) to place an order 
    for the raw material for the product. Here we use order number, which is to identify the order and also the same 
    product identification number created for the customer's order to refer the product. To place an order to the supplier, 
    IBO  provides the hashes of the documents, agreed off-chain with the supplier. After reviewing the order requirements, 
    supplier and IBO can change requirements and request other parties agreement for those changes. The supplier can p
    roceed to work on the order after both parties agreed on the specifications. Once the order is ready, IBO starts 
    manufacturing the product. When the product is completed, IBO sells that product to RetailerX. Then retailer sells 
    that product to end customer called Customer1. Customer can query the product information using the Customer Portal,
    which is open for public. Customers or any other party can view the history of the product and also verify product 
    authenticity.

##### Steps

Please use following addresses to access frontend clients

IBO - http://localhost:8081/

SupplierA - http://localhost:8082/

Retailer - http://localhost:8084/

Customer - http://localhost:8083/

1. Goto IBO front and login. Use username: admin, password: admin as credentials

    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/IBOlogin.png)

2. Goto Orders->Create Product in IBO frontend page

    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibocreateorder.png)

3. Fill the order details. You can get hashes of the document by uploading the documents to IPFS using the client mentioned in
   "Run Frontend Application section"    
    
    Note: Here we are creating a product with identification number **IBO0100**. You are supposed to use the same ID throughout 
          the demo
      
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibocustomerorder.png)
   
4. Next IBO places an supply order for to get material to SupplierA. In IBO frontend click on Supplier-> Place Supplier Order.

      ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibosupplierorder.png)

   Here IBO and the supplier agree on the documents offchain and you can fill the form. Use **IBO0100** as product ID.
   This solution provides simple and reliable trustful method to discuss and agree on order requirement changes enabling 
   all parties to come to a common ground on requirements. 
   
   For the demo, we use one requirements filed - description, where IBO and Suppier making chages back and forth, then
   agree. Notice the descripion field "Medium-carbon steel of 0.30 wt% carbon"
      
      ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibosupplierorderform.png)
   
   After placing orders, IBO can see the status of orders. Here IBO can see the status of the order and specially 
   IBO can check whether the supplier has agreed on the changes made by IBO or not. 
   Click on Supplier-> Order Status
   
      ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/iboorderstatus.png)
          
5. Now check the order from SupplierA client application. Goto SupplierA frontend and login using admin,admin credential
      
      ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierlogin.png)
      
6. Supplier check the order. 

    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/suppliervieworders.png)
   
   Click on Order status to view orders

    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierordertable.png)

   Here Supplier can see IBO has already agreed for the order details. Click view button to view order details
   But the supplier wants to make change in the product description. (Change "Medium-carbon steel of 0.25 wt% carbon"). 
   The supplier makes that change and click update button to update the order.
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierchnage1.png)
    
7. Now click again on the Orders status to see the status of the order. Now the supplier can see that IBO hasn't 
   agreed for the changes yet.
   
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierordertable2.png)
    
8. Now IBO view the change again and propose another change. Goto IBO portal and click on Supplier->Order status to see 
   orders. Click view button of the order to view order details.
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/iboordertable2.png)
   
   IBO doesn't accept the change from the SupplierA. Instead, it request adjustment to the change. 
   Proposes : Change "Medium-carbon steel of 0.28 wt% carbon"
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibochnage1.png)

9. SupplierA view the order and propose another change. Go to SupplierA portal and click on the Order Status to view orders.
   Supplier can see IBO has agreed on a new change.
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierordertable3.png)
   
   But the supplier want to make another change. Click view button and make the change in the description filed.
   Proposes : Change "Medium-carbon steel of 0.27 wt% carbon"
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierchange2.png)
   
10. IBO view the order and agree the change made by the supplier. Goto IBO portal. Click Supplier->Order status and then view 
   button of the order. Then click "Agree" button
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/iboagree.png)
   
11. SupplierA view the order summary and verify that IBO has agreed for the changes and start progress on the order. 
   Goto supplier portal and click on Orders status. Then click on view order button
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierordertable4.png) 

   Here supplier change the status of the product to "Started working"
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/supplierstartworking.png) 
   
12. IBO can always check the status of the order until it is completed. Goto IBO portal and view orders to check the status
   of the order.
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibostatus.png) 
   
13. After some time, the supplier marks the status of the order as "Completed"
   and inform IBO the status. Goto suppler portal and view orders and then update the status of the order to "Completed"
   
   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/suppliercomplete.png) 
   
14. IBO verify the supply order status

   ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/IBOComplete.png) 

    Then IBO start working on the product, manufacture it.
    
15. When product is completed, IBO is ready to sell product to a retailer called RetailerX. Goto IBO portal and click on Sell.

    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibosell1.png)
    
    Fill the form providing the product ID as **IBO0100** and other relevant details. Finally click "Sell" button.
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/ibosell2.png)
    
16. Retailerx sells the product with id IBO0100 to ebd customer. Goto retailer portal and login with admin,admin credentials

    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/retailerlogin.png)
    
    Click on "Sell Product" button.
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/retailersell1.png)
    
    Fill the form providing product ID as **IBO0100** and other relevant information
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/retailersell3.png)
    
17. Customer verifies the authenticity of the product and the history of the product. Goto customer portal and click on
    Product Information
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/retailersell3.png)
    
    Provide prodict ID **IBO0100**
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/productinfo.png)
    
    To get product history, click on Product History, provide product ID **IBO0100**, click View Info
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/producthistory.png)
    
    If the product in not authentic, this portal will show, invalid product message
    
    ![alt text](https://raw.githubusercontent.com/malinthasa/BC4SCM/master/demo/images/invalidproduct.png)
    
    
# 
### Architecture of the system

   **Root Project Folder BC4SCM**
     
    ├── chaincode - {Includes the chaincodes of separate Organizations}
    ├── demo      - {Includes the vedio of the demo}
    ├── frontend  - {Includes front end code for each Organization}
    ├── network   - {Includes Hyperledger network preparation code}
    └── readme.md
    
# chaincode Folder

   **chaincode Folder** - {Chaincode folder}
    
    ├── readme.md
    └── scmlogic
    
   **scmlogic Folder** - {scmlogic Folder contains chaincodes for each organization}
   
    ├── ibocustomers
    ├── ibologistics
    ├── iboretailers
    └── ibosuppliers
    
# frontend Folder
    
   **frontend Folder** {frontend Folder constains frontend clients for each organization}
    
    ├── Customer
    ├── IBO
    ├── Logistic
    ├── prepare_client_environments.sh
    ├── Retailer
    ├── SupplierA
    └── SupplierB
    
   **Customer Folder** {ex: Customer Folder contains frontend application of the Customer client application}
   
    ├── frontend
    ├── source
    └── start-client.sh
    
    
   **frontend Folder** {ex: frontend flder inside each client contains html files}
   
    ├── credits.txt
    ├── history.html
    ├── index.html
    ├── info.html
    ├── license.txt
    ├── readme.txt
    └── resources
    
    
   **source Folder** {ex: source folder inside each client contains chaincode clients and other utilities}
   
    ├── customerfrontend.js
    ├── enrollGenericAdmin.js
    ├── getProductHistory.js
    ├── node_modules
    ├── package.json
    ├── package-lock.json
    ├── productInfo.js
    ├── productInfoService.js
    ├── registerGenericAffliation.js
    ├── registerGenericUser.js
    └── wallet

# network Folder

   **network Folder** {network Folder contains Fabric network docker files and other configuration files}
   
    ├── base
    ├── bin
    ├── channel-artifacts
    ├── configtxgen
    ├── configtxlator
    ├── configtx.yaml
    ├── connection-customer.json
    ├── connection-ibo.json
    ├── connection-logistic.json
    ├── connection-retailer.json
    ├── connection-supplierA.json
    ├── connection-supplierB.json
    ├── connection-supplier.json
    ├── crypto-config
    ├── crypto-config.yaml
    ├── cryptogen
    ├── discover
    ├── docker-compose-ca.yaml
    ├── docker-compose-cli.yaml
    ├── docker-compose-couch-org3.yaml
    ├── docker-compose-couch.yaml
    ├── docker-compose-e2e-template.yaml
    ├── docker-compose-e2e.yaml
    ├── fabric-ca-client
    ├── idemixgen
    ├── orderer
    ├── peer
    ├── reset.sh
    ├── scmnetwork.sh
    ├── scripts
    └── startFabric.sh


# 
### Known bugs or errors

Bugs and error are listed below based on the severity


1. Level0
          
      Sometimes, the demo scenario faces inconsistent errors. If you are not getting the expected value in the browser UI, refresh the browser before you try again.

1. Level1
          
      If refreshing the browser doesn't resolve the problems, restart the client.

2. Level1
 
      If something is not working even after  restarting the client/s, reinstall the apllication from the begining will solve the issue.