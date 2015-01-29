package main

import (
	"testing"

	"github.com/zeromq/goczmq"
)

func TestHelloServer(t *testing.T) {
	go func() {
		s := NewHelloServer("inproc://hello_server")

		if s.Endpoint() != "inproc://hello_server" {
			t.Errorf("endpoint wanted %s got %s", "inproc://hello_server", s.Endpoint())
		}

		s.Listen()
	}()

	client := goczmq.NewSock(goczmq.REQ)
	client.Connect("inproc://hello_server")

	client.SendFrame([]byte("Hello"), 0)
	resp, _, err := client.RecvFrame()
	if err != nil {
		t.Errorf("client.RecvFrame(): %s", err)
	}

	if string(resp) != "Hello World" {
		t.Errorf("server should respond 'Hello World' but got %s", string(resp))
	}

	client.SendFrame([]byte("Not Hello"), 0)
	resp, _, err = client.RecvFrame()
	if err != nil {
		t.Errorf("client.RecvFrame(): %s", err)
	}

	if string(resp) != "Error" {
		t.Errorf("server should respond with 'Error' to bad input but got %s", string(resp))
	}
}
