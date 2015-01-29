package main

import (
	"fmt"
	"time"

	"github.com/zeromq/goczmq"
	"github.internal.digitalocean.com/digitalocean/doge.git/log"
)

func main() {

	go func() {
		publisher := goczmq.NewSock(goczmq.PUB)
		publisher.Bind("tcp://*:6665")
		for {
			publisher.SendFrame([]byte("157:6666"), 0)
			time.Sleep(1 * time.Second)
		}
	}()

	router := goczmq.NewSock(goczmq.ROUTER)
	router.Bind("tcp://*:6666")

	for {
		msg, err := router.RecvMessage()
		if err != nil {
			log.Errorf("error: %s\n", err)
		}

		if len(msg) == 2 {
			fmt.Printf("received: %s\n", string(msg[1]))
			msg[1] = []byte("hello from @taotetek")
			err = router.SendMessage(msg)
			if err != nil {
				log.Errorf("error: %s\n", err)
			}
		}
	}
}
