var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
const path = require('path');
const router = express.Router();
var sellService = require('./sellService');
app.use(express.static(path.join(__dirname + "/.." + "/frontend", '/resources')));

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/login.html'));
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/index.html'));
});


router.get('/sell',function(req,res){
    res.sendFile(path.join(__dirname + "/.." + "/frontend"+ '/sellProduct.html'));
});


app.get('/retailer/sell', function(req, res) {
  details = sellService.sellProduct(req.query.pid, req.query.cutomerId, req.query.date).then(function(result) {
    console.log(result)
    res.send(result);
});
});

app.get('/retailer/return', function(req, res) {
  details = sellProduct.sellProduct(req.query.pid, req.query.cutomerId, req.query.date).then(function(result) {
    console.log(result)
    res.send(result);
});
});

app.use('/', router);
app.listen(process.env.port || 3005);

console.log('Running at Port 8084');

// Running Server Details.
var server = app.listen(8084, function () {
  var host = server.address().address
  var port = server.address().port
});
