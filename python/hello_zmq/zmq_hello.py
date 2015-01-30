# coding=utf-8

"""
A hello world example using ZMQ

Usage:
    zmq_hello [options] server <secret>
    zmq_hello [options] client

Options:
    -h --help                   Show this help menu

    --pub-port=<pub-port>       Port to publish discovery information on [default: 6665]
"""
import sys
import socket
import logging
import zmq
import netifaces
import ipaddress
from time import sleep
from datetime import datetime
from threading import Thread
from IPy import IP
from docopt import docopt

log = logging.getLogger(__name__)

CLIENT_RECEIVE_TIMEOUT = 300
CLIENT_HIGH_WATER_MARK = 600

def _client(opts):
    pub_port = int(opts['--pub-port'])
    ifaces = netifaces.interfaces()
    networks = list()
    found_clients = dict()

    def dump_seen_clients():
        print "\n### Seen Dump ###"
        for uri, seen in found_clients.items():
            print "#", uri, seen
        print "############\n"

    for iface in ifaces:
        if iface == "lo":
            continue
        aux = netifaces.ifaddresses(iface).items()
        if len(aux) > 1:
            addr = aux[1][1][0]["addr"]
            mask = aux[1][1][0]["netmask"]
            networks.append(IP(addr).make_net(mask))

    ctx = zmq.Context()
    sub_socket = ctx.socket(zmq.SUB)
    sub_socket.setsockopt(zmq.SUBSCRIBE, b"")
    sub_socket.hwm = CLIENT_HIGH_WATER_MARK  # set the high water mark so we don't get bogged down by clients not responding

    # connect to all the addrs
    for network in networks:
        log.info('publishing to {}'.format(network))
        for dst_ip in network:
            sub_socket.connect('tcp://{}:{}'.format(dst_ip, pub_port))
        
    network_prefix = '.'.join(socket.gethostbyname(socket.gethostname()).split(".")[:-1])

    while True:
        msg = sub_socket.recv_string()
        uri = network_prefix+"."+msg
        found_clients[uri] = datetime.now()
        dump_seen_clients()

        try:
            last_octet, port = msg.split(':')
            lzmast_octet = int(last_octet)
            port = int(port)
            client_addr = '{}.{}'.format(network_prefix, last_octet)
            log.debug('trying to connect to {}:{}'.format(client_addr, port))

            dealer_socket = ctx.socket(zmq.DEALER)
            dealer_socket.setsockopt(zmq.RCVTIMEO, CLIENT_RECEIVE_TIMEOUT)
            endpoint = 'tcp://{}:{}'.format(client_addr, port)
            dealer_socket.connect(endpoint)
        except ValueError:
            continue

        try:
            dealer_socket.send_string('Hello')
            reply = dealer_socket.recv_string()
            log.info('{} says {!r}'.format(endpoint, reply))
            dealer_socket.close()
        except zmq.Again:
            log.debug('Client {} unavailable!'.format(endpoint))
        except Exception:
            log.debug('Eek', exc_info=True)


def _server(opts):
    pub_port = int(opts['--pub-port'])
    last_octet = socket.gethostbyname(socket.gethostname()).split(".")[-1]
    secret = opts['<secret>']

    # start the pub socket
    ctx = zmq.Context()
    pub_sock = ctx.socket(zmq.PUB)
    pub_sock.bind('tcp://*:{}'.format(pub_port))

    router_sock = ctx.socket(zmq.ROUTER)
    router_port = router_sock.bind_to_random_port('tcp://*')

    print("Hello router will listen on {}".format(router_port))

    def server_hello():
        while True:
            try:
                client_id, msg = router_sock.recv_multipart()
                msg = msg.decode('ascii')
                if msg == 'Hello':
                    router_sock.send_multipart([client_id, secret.encode('ascii')])
                else:
                    router_sock.send_multipart([client_id, 'Error'.encode('ascii')])
            except UnicodeDecodeError:
                log.error('Error decoding', exc_info=True)


    router_thread = Thread(target=server_hello)
    router_thread.start()

    while True:
        pub_sock.send_string('{}:{}'.format(last_octet, router_port))
        sleep(1)


def main(opts):
    if opts['client']:
        return _client(opts)
    elif opts['server']:
        return _server(opts)
    else:
        raise ValueError("Unknown top-level command")

if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)-15s %(message)s', level=logging.INFO)

    sys.exit(main(docopt(__doc__)))