package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"strconv"
)

func main() {
	ip := net.ParseIP("127.0.0.1")
	port := 30000
	if len(os.Args) > 1 {
		if ip = net.ParseIP(os.Args[1]); ip == nil {
			fmt.Printf("parse %s failed\n", os.Args[1])
			os.Exit(1);
		}
	}

	if len(os.Args) > 2 {
		port, _ = strconv.Atoi(os.Args[2])
	}
	fmt.Println("netcat-go")

	listen, err := net.ListenUDP("udp", &net.UDPAddr{
		IP:   ip,
		Port: port,
	})

	if err != nil {
		log.Println("Listen failed, err: ", err)
		return
	}
	fmt.Printf("listen at: %s:%d\n", ip.String(), port)
	defer listen.Close()
	for {
		var data [1500]byte
		n, addr, err := listen.ReadFromUDP(data[:]) // 接收数据
		if err != nil {
			fmt.Println("read udp failed, err: ", err)
			continue
		}
		fmt.Printf("data:%v addr:%v count:%v\n", string(data[:n]), addr, n)
		_, err = listen.WriteToUDP(data[:n], addr) // 发送数据
		if err != nil {
			fmt.Println("Write to udp failed, err: ", err)
			continue
		}
	}
}
