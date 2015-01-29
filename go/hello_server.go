package main

import "github.com/zeromq/goczmq"

type HelloServer struct {
	sock     *goczmq.Sock
	endpoint string
}

func (s *HelloServer) Endpoint() string {
	return s.endpoint
}

func NewHelloServer(endpoint string) *HelloServer {
	s := &HelloServer{endpoint: endpoint}
	s.sock = goczmq.NewSock(goczmq.REP)
	return s
}

func (s *HelloServer) Listen() error {
	_, err := s.sock.Bind(s.endpoint)
	if err != nil {
		return err
	}

	for {
		msg, _, err := s.sock.RecvFrame()
		if err != nil {
			return err
		}

		if string(msg) == "Hello" {
			s.sock.SendFrame([]byte("Hello World"), 0)
		} else {
			s.sock.SendFrame([]byte("Error"), 0)
		}
	}
}
