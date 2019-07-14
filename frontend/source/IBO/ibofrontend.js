var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
var productService = require('./registerProduct');
var orderService = require('./registerOrder');
var ordersQueryService = require('./orderService');
var ordesQueryService = require('./ordersService');
var agreeSupply = require('./agreeSupplyChanges');
var sellProduct = require('./sellService');
const path = require('path');
const router = express.Router();
app.use(express.static(path.join(__dirname + "/frontend", '/resources')));

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend"+ '/login.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend"+ '/index.html'));
});

router.get('/adminPanel',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend"+ '/adminPanel.html'));
});

router.get('/supply',function(req,res){
    res.sendFile(path.join(__dirname + "/frontend"+ '/pendingOrders.html'));
});

router.get('/placeorder',function(req,res){
    res.sendFile(path.join(__dirname + "/frontend"+ '/placeSupplyOrder.html'));
});


router.get('/orders',function(req,res){
    res.sendFile(path.join(__dirname + "/frontend"+ '/customerOrder.html'));
});

router.get('/sell',function(req,res){
    res.sendFile(path.join(__dirname + "/frontend"+ '/sellProduct.html'));
});

app.get('/supplier/orders', function(req, res) {
  details = orderService.registerOrder(req.query.oid, req.query.pid, req.query.chash, req.query.rhash, req.query.shash, req.query.serial, req.query.desc, req.query.date).then(function(result) {
    console.log(result)
    res.send(result);
});

});

app.get('/ibo/sell', function(req, res) {
  details = sellProduct.sellProduct(req.query.pid, req.query.cutomerId, req.query.date).then(function(result) {
    console.log(result)
    res.send(result);
});

});



app.get('/customer/addorder', function(req, res) {
  details = productService.registerProduct(req.query.oid, req.query.pid, req.query.chash, req.query.rhash, req.query.shash, req.query.serial, req.query.desc, req.query.date).then(function(result) {
    console.log(result)
    res.send(result);
});

});



app.get('/ibo/viewAllSupplyOrders', function(req, res) {
  details = ordersQueryService.getOrders().then(function(result) {
    console.log(result)
    res.send(result);
});

});

app.get('/ibo/viewSupplyOrder', function(req, res) {
  details = ordesQueryService.getOrder(req.query.id).then(function(result) {
    console.log(result)
    res.send(result);
});

});

app.get('/ibo/agreeOrder', function(req, res) {
  details = agreeSupply.agreeSupplyChange(req.query.id).then(function(result) {
    console.log(result)
    res.send(result);
});

});


router.get('/order',function(req,res){
  res.sendFile(path.join(__dirname + "/frontend"+ '/order.html'));
});

//add the router
app.use('/', router);
app.listen(process.env.port || 3000);

console.log('Running at Port 3000');

// Running Server Details.
var server = app.listen(8081, function () {
  var host = server.address().address
  var port = server.address().port
});
