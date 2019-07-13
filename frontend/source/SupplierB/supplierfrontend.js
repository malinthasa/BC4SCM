var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
var productService = require('./addPrivateData');
const path = require('path');
const router = express.Router();
app.use(express.static(path.join(__dirname + "/../Suppliers", 'resources')));

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/../Suppliers"+ '/login.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/../Suppliers"+ '/index.html'));
});

router.get('/network',function(req,res){
  res.sendFile(path.join(__dirname + "/../Suppliers"+ '/network.html'));
});

router.get('/transactions',function(req,res){
    res.sendFile(path.join(__dirname + "/../Suppliers"+ '/transactions.html'));
});

app.get('/supplier/addorder', function(req, res) {
   productService.main();

});

//add the router
app.use('/', router);
app.listen(process.env.port || 3001);

console.log('Running at Port 3001');

// Running Server Details.
var server = app.listen(8082, function () {
  var host = server.address().address
  var port = server.address().port
  console.log("Retialer app listening at %s:%s Port", host, port)
});
