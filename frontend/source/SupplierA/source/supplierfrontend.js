var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
var orderService = require('./orderService');
var ordersService = require('./ordersService');
var updateService = require('./updateService');
var updateServiceStatus = require('./updateOrderStatus');
var updateProductService = require('./updateProductStatus');
var updateServiceAgree = require('./updateProductAgree');

const path = require('path');
const router = express.Router();
app.use(express.static(path.join(__dirname + "/.." + "/frontend", '/resources')));

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/login.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/index.html'));
});

router.get('/orders',function(req,res){
  res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/pendingOrders.html'));
});

router.get('/order',function(req,res){
  res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/order.html'));
});

router.get('/vieworder',function(req,res){
    res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/viewSupplyOrder.html'));
});

app.get('/supplier/getorder', function(req, res) {

  details = ordersService.getOrder(req.query.id).then(function(result) {

  res.send(result);

});
});

app.get('/supplier/updateProduct', function(req, res) {

  details = updateProductService.updateProductStatus(req.query.pid, req.query.status, req.query.date).then(function(result) {

  res.send(result);

});
});




app.get('/supplier/updateOrder', function(req, res) {

  details = updateService.updateOrder(req.query.id, req.query.des, req.query.ibo, req.query.supplier).then(function(result) {

  res.send(result);

});
});
app.get('/supplier/updateOrderStatus', function(req, res) {

  details = updateServiceStatus.updateOrderStatus(req.query.id, req.query.status).then(function(result) {

  res.send(result);

});
});


app.get('/supplier/agreeOrder', function(req, res) {

  details = updateServiceAgree.updateAgree(req.query.id).then(function(result) {

  res.send(result);

});
});

app.get('/supplier/viewAllOrders', function(req, res) {
  details = orderService.getOrders().then(function(result) {
    console.log(result)
    res.send(result);

});

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
