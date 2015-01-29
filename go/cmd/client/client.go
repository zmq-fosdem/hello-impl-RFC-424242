package main

import (
	"fmt"
	"strings"

	"github.com/zeromq/goczmq"
)

func main() {
	tellme := make(chan []byte)

	go func() {
		var endpoints []string
		for i := 1; i < 255; i++ {
			endpoints = append(endpoints, fmt.Sprintf("tcp://192.168.1.%d:6665", i))
		}

		list := strings.Join(endpoints, ",")
		s, _ := goczmq.NewSUB(list, "")
		for {
			advert, _, err := s.RecvFrame()
			if err != nil {
				panic(err)
			}
			fmt.Printf("advert: %s\n", advert)
			tellme <- advert
		}
	}()

	for {
		advert := <-tellme
		dealer := goczmq.NewSock(goczmq.DEALER)
		endpoint := fmt.Sprintf("tcp://192.168.1.%s", string(advert))
		fmt.Printf("connecting to: %s\n", endpoint)
		err := dealer.Connect(endpoint)
		if err != nil {
			continue
		}
		err = dealer.SendFrame([]byte("Hello"), 0)
		if err != nil {
			fmt.Println(err)
			continue
		}

		poller, _ := goczmq.NewPoller(dealer)
		defer poller.Destroy()
		s := poller.Wait(5000)
		if s != nil {
			reply, _, err := s.RecvFrame()
			if err != nil {
				fmt.Println(err)
				continue
			}

			fmt.Printf("received: %s\n", string(reply))
		}
		dealer.Destroy()
	}
}
