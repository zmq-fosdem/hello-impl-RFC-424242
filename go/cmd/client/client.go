package main

import (
	"fmt"
	"strings"

	"github.com/zeromq/goczmq"
)

func main() {
	var endpoints []string
	for i := 1; i < 255; i++ {
		endpoints = append(endpoints, fmt.Sprintf("tcp://192.168.1.%d:6666", i))
	}

	list := strings.Join(endpoints, ",")
	s, _ := goczmq.NewDEALER(list)
	for i := 0; i < 1000; i++ {
		s.SendFrame([]byte("Hello"), 0)
	}

	for i := 0; i < 255; i++ {
		msg, _, _ := s.RecvFrame()
		fmt.Printf("%v\n", string(msg))
	}
}
