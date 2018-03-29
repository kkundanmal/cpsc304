
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');

//load customers route
var customers = require('./routes/customers'); 
const locations = require('./routes/locations');
const items = require('./routes/items');
var app = express();

var connection  = require('express-myconnection'); 
var mysql = require('mysql');

// all environments
app.set('port', process.env.PORT || 4300);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
//app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());

app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

/*------------------------------------------
    connection peer, register as middleware
    type koneksi : single,pool and request 
-------------------------------------------*/

app.use(
    
    connection(mysql,{
        
        
            host     : 'am1shyeyqbxzy8gc.cbetxkdyhwsb.us-east-1.rds.amazonaws.com',
            user     : 'pp7dkd3u2lrpa26k',
            password : 'zm4zqrcymmy94y4o',
            database : 'yv43wx0kfvvxcs0q'
        

    },'pool') //or single

);

app.get('/', routes.index);



// CUSTOMER ROUTES
app.get('/customers', customers.list);
app.get('/customers/add', customers.add);
app.post('/customers/add', customers.save);
app.get('/customers/delete/:id', customers.delete_customer);
app.get('/customers/edit/:id', customers.edit);
app.post('/customers/edit/:id',customers.save_edit);

// Inventory Items Route
app.get('/', routes.index);
app.get('/items', items.list);
app.get('/items/add', items.add);
app.post('/items/add', items.save);
app.get('/items/delete/:id', items.delete);
app.get('/items/edit/:id', items.edit);
app.post('/items/edit/:id',items.save_edit);

// Locations ROUTES
app.get('/locations', locations.list);
// app.get('/locations/add', customers.add);
// app.post('/locations/add', customers.save);
// app.get('/locations/delete/:id', customers.delete_customer);
// app.get('/locations/edit/:id', customers.edit);
// app.post('/locations/edit/:id',customers.save_edit);

// Purchase Records
app.get('/records', customers.list);
app.get('/records/add', customers.add);
app.post('/records/add', customers.save);
app.get('/records/delete/:id', customers.delete_customer);
app.get('/records/edit/:id', customers.edit);
app.post('/records/edit/:id',customers.save_edit);



app.use(app.router);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
