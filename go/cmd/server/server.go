package main

import (
	"github.com/zeromq/goczmq"
	"github.internal.digitalocean.com/digitalocean/doge.git/log"
)

func main() {
	s := goczmq.NewSock(goczmq.ROUTER)
	s.Bind("tcp://*:6666")
	for {
		msg, err := s.RecvMessage()
		if err != nil {
			log.Errorf("error: %s\n", err)
		}

		if len(msg) == 2 {
			if string(msg[1]) == "Hello" {
				msg[1] = []byte("hello from taotetek")
			} else {
				msg[1] = []byte("Error")
			}
			err = s.SendMessage(msg)
			if err != nil {
				log.Errorf("error: %s\n", err)
			}
		}
	}
}
