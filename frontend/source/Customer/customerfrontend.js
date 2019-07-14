var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
var productService = require('./productInfo');
var productService1 = require('./productInfoService');
const path = require('path');
const router = express.Router();
app.use(express.static(path.join(__dirname + "/frontend/", 'resources')));


router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend/"+ '/index.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend/"+ '/index.html'));
});

router.get('/info',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend/"+ '/info.html'));
});

router.get('/history',function(req,res){
    res.sendFile(path.join(__dirname + "/frontend/"+ '/history.html'));
});

app.get('/customers/productInfo', function(req, res) {
  details = productService.getProductDetails(req.query.prid).then(function(result) {
    console.log(result)
    res.send(result);
});

});

app.get('/customers/productHistory', function(req, res) {
  details = productService1.getProductHistory(req.query.prid).then(function(result) {
    console.log(result)
    res.send(result);
});

});

//add the router
app.use('/', router);
app.listen(process.env.port || 3004);

console.log('Running at Port 3000');

// Running Server Details.
var server = app.listen(8083, function () {
  var host = server.address().address
  var port = server.address().port
  console.log("Customer app listening at %s:%s Port", host, port)
});

// });
