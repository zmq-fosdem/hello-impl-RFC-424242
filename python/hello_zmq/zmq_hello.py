# coding=utf-8

"""
A hello world example using ZMQ

Usage:
    zmq_hello [options] server
    zmq_hello [options] client <remote_addr>

Options:
    -h --help           Show this help menu

    --port=<port>       Port to bind to/connect to [default: 6666]
"""
from docopt import docopt
import sys
import zmq


def _client(opts):
    port_num = int(opts['--port'])
    remote_addr = opts['<remote_addr>']

    ctx = zmq.Context()
    socket = ctx.socket(zmq.REQ)
    socket.connect('tcp://{}:{}'.format(remote_addr, port_num))

    msg = 'Hello'
    socket.send_string(msg)
    reply = socket.recv_string()

    print(reply)


def _server(opts):
    port_num = int(opts['--port'])

    ctx = zmq.Context()
    socket = ctx.socket(zmq.REP)
    socket.bind('tcp://*:{}'.format(port_num))

    while True:
        msg = socket.recv_string()
        if msg == 'Hello':
            socket.send_string('Hello world')
        else:
            socket.send_string('Error')


def main(opts):
    if opts['client']:
        return _client(opts)
    elif opts['server']:
        return _server(opts)
    else:
        raise ValueError("Unknown top-level command")

if __name__ == '__main__':
    sys.exit(main(docopt(__doc__)))