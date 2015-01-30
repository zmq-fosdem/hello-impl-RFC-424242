var async = require('async');
var zmq = require('zmq');

var PUB_PORT = '6665';
var SUBNET = '192.168.1';
var IP_LAST_OCTET = '39';
var HOST = SUBNET + '.' + IP_LAST_OCTET;

function makeRequest(octetAndPort) {
  var address = 'tcp://' + SUBNET + '.' + octetAndPort;
  console.log('Client will make request to ' + address);
  var dealer = zmq.socket('dealer');
  dealer.identity = HOST + '/' + process.pid;
  dealer.connect(address);
  dealer
    .on('message', function onDealerMessage(message) {
      console.log('Client received response ' + message.toString());
    })
    .on('error', function onDealerError(err) {
      console.log('Client received error ' + err.toString());
    });
  dealer.send('Hello');
}

function connect(host, port, cb) {
  var socket = zmq.socket('sub');
  socket.identity = new Buffer(HOST + '/' + process.pid, 'utf8');
  var connstr = 'tcp://' + host + ':' + port;
  console.log('Trying ' + connstr + '...');
  socket.connect(connstr);
  socket
    .on('message', function (message) {
      console.log('Subscription result: ' + message.toString());
      if (!message) {
        console.log('Error: Message missing!');
      } else {
        var serverAddr = message.toString();
        console.log('Discovered ' + serverAddr + ' from ' + connstr);
        makeRequest(serverAddr);
      }
      socket.close();
      return cb(null);
    })
    .on('error', function (err) {
      console.log('Got error from ' + connstr, err.toString());
      socket.close();
      return cb(err);
    });
  socket.subscribe('');
}

var addrs = [];
for (var i = 0; i < 256; ++i) {
  var ip = SUBNET + '.' + i;
  addrs[i] = ip;
}
var jobs = [];
addrs.forEach(function (host) {
  jobs.push(connect.bind(null, host, PUB_PORT));
});
async.parallel(jobs, function (err) {
  if (err) {
    console.log('Got error: ' + err.toString());
  } else {
    console.log('got no error');
  }
});
