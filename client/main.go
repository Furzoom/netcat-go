package main

import (
	"fmt"
	"net"
	"os"
	"strconv"
	"syscall"
)

func main() {
	if err := syscall.Setgid(3003); err != nil {
		fmt.Printf("setgdi failed: %s", err)
	}
	gids := []int{3003, 3004, 3005, 3006, 3007, 3008}
	if err := syscall.Setgroups(gids); err != nil {
		fmt.Printf("setgroups failed: %s", err)
	}
	ip := net.ParseIP("127.0.0.1")
	port := 30000
	if len(os.Args) > 1 {
		if ip = net.ParseIP(os.Args[1]); ip == nil {
			fmt.Printf("parse %s failed\n", os.Args[1])
			os.Exit(1)
		}
	}
	if len(os.Args) > 2 {
		port, _ = strconv.Atoi(os.Args[2])
	}

	srcAddr := &net.UDPAddr{IP: net.IPv4zero, Port: 0}
	dstAddr := &net.UDPAddr{IP: ip, Port: port}
	conn, err := net.DialUDP("udp", srcAddr, dstAddr)
	if err != nil {
		fmt.Println(err)
	}
	defer conn.Close()
	conn.Write([]byte("hello"))
	data := make([]byte, 1024)
	n, err := conn.Read(data)
	fmt.Printf("read %s from <%s>\n", data[:n], conn.RemoteAddr())
}
