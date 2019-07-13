var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
// var productService = require('./productInfo');
const path = require('path');
const router = express.Router();
app.use(express.static(path.join(__dirname + "/../Customers", 'resources')));


router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/../Customers"+ '/index.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/../Customers"+ '/index.html'));
});

router.get('/info',function(req,res){
  res.sendFile(path.join(__dirname + "/../Customers"+ '/info.html'));
});

router.get('/history',function(req,res){
    res.sendFile(path.join(__dirname + "/../Customers"+ '/history.html'));
});

// app.get('/customers/products', function(req, res) {
//   details = productService.getProductDetails().then(function(result) {
//     console.log(result)
//     res.send(result);
// });

// });

//add the router
app.use('/', router);
app.listen(process.env.port || 3000);

console.log('Running at Port 3000');

// Running Server Details.
var server = app.listen(8083, function () {
  var host = server.address().address
  var port = server.address().port
  console.log("Customer app listening at %s:%s Port", host, port)
});

// });
