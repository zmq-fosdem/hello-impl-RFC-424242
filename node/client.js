var zmq = require('zmq');

var host = process.argv[2] || '127.0.0.1';
var address = 'tcp://' + host + ':6666';
var msg = 'Hello';
console.log('Connecting to: %s', address);

var socket = zmq.socket('req');
socket.connect(address);

console.log('Sending message: "%s"', msg);
socket.send('Hello');
socket.once('message', onMsg);

function onMsg(data) {
  var str = data.toString();
  console.log('Client received: "%s"', str);
  process.exit(0);
}
