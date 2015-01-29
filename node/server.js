var zmq = require('zmq');

var socket = zmq.socket('rep');
socket.bind('tcp://*:6666');
socket.on('message', onMsg);

function onMsg(data) {
  var str = data.toString();
  console.log('Client received: "%s"', str);

  if (str !== 'Hello')
    return;

  socket.send('Hello world');
}
