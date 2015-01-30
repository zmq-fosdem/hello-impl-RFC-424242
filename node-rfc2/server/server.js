var zmq = require('zmq');

var SECRET_STRING = '@lukeb0nd';
var ERROR_STRING = 'Error';
var IP_LAST_OCTET = '39';
var HOST = '192.168.1.' + IP_LAST_OCTET;
var PUB_PORT = '6665';
var ROUTER_PORT = '26666';
var TOPIC = 'discovery';
var PUB_ADDR = 'tcp://' + HOST + ':' + PUB_PORT;
var ROUTER_ADDR = 'tcp://' + HOST + ':' + ROUTER_PORT;
var PUBLISH_STRING = IP_LAST_OCTET + ':' + ROUTER_PORT;

var routerSocket = zmq.socket('router');
routerSocket
  .bindSync(ROUTER_ADDR)
  .on('message', function onRouterMessage(envelope, data) {
    var message = data.toString();
    console.log('onRouterMessage: received ' + envelope + ' - ' + message);
    if (message === 'Hello') {
      routerSocket.send([envelope, SECRET_STRING]);
    } else {
      routerSocket.send([envelope, ERROR_STRING]);
    }
  })
  .on('error', function onRouterError(err) {
    console.log('onRouterError ' + err.toString());
  });

var pubSocket = zmq.socket('pub');

function announce() {
  console.log('Broadcasting ' + PUBLISH_STRING);
  pubSocket.send(PUBLISH_STRING);
}

pubSocket
  .bindSync(PUB_ADDR)
  .on('error', function onPubError(err) {
    console.log('onPubError ' + err.toString());
  });
setInterval(announce, 1000);
