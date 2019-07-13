var http = require("http");
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var urlencodedParser = bodyParser.urlencoded({ extended: true });
var productService = require('./orderInfo');
const path = require('path');
const router = express.Router();
app.use(express.static(path.join(__dirname + "/../IBO", 'resources')));

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname + "/../IBO"+ '/login.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/home',function(req,res){
  res.sendFile(path.join(__dirname + "/../IBO"+ '/index.html'));
});

router.get('/network',function(req,res){
  res.sendFile(path.join(__dirname + "/../IBO"+ '/network.html'));
});

router.get('/transactions',function(req,res){
    res.sendFile(path.join(__dirname + "/../IBO"+ '/transactions.html'));
});

app.get('/supplier/orders', function(req, res) {
  details = productService.getProductDetails().then(function(result) {
    console.log(result)
    res.send(result);
});

});

//add the router
app.use('/', router);
app.listen(process.env.port || 3000);

console.log('Running at Port 3000');

// Running Server Details.
var server = app.listen(8081, function () {
  var host = server.address().address
  var port = server.address().port
  console.log("Retialer app listening at %s:%s Port", host, port)
});


app.get('/RetrailerView', function (req, res) {
  var html='';
  html +="<body>";
  html += "<form action='/getItemInfo'  method='post' name='form1'>";
  html += "Item ID:</p><input type= 'text' name='itemid'>";
  html += "<input type='submit' value='submit'>";
  html += "</form>";
  html += "</body>";
  res.send(html);
});

app.post('/getItemInfo', urlencodedParser, function (req, res){

  var reply='';
  reply += "Item Details";
  details = productService.getProductDetails(req.body.itemid).then(function(result) {
    bearing = JSON.parse(JSON.parse(result))
    reply += "<br/>";
    reply += "<br/>";
    reply += bearing.id;
    reply += "<br/>"
    reply += bearing.docType;
    reply += "<br/>"
    reply += bearing.type;
    reply += "<br/>"
    reply += bearing.batchno;
    reply += "<br/>"
    reply += bearing.date;
    res.send(reply);
});



 });
