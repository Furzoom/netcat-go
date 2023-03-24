package main

import (
	"flag"
	"fmt"
	"net"
	"os"
	"syscall"
	"time"
)

type Option struct {
	RemoteIP   string
	RemotePort int
	LocalIP    string
	LocalPort  int
	Count      int
}

func main() {
	SetGroups()
	option := &Option{}

	flag.StringVar(&option.RemoteIP, "rip", "127.0.0.1", "remote address")
	flag.StringVar(&option.LocalIP, "lip", "0.0.0.0", "local address")
	flag.IntVar(&option.RemotePort, "rport", 30000, "remote port")
	flag.IntVar(&option.LocalPort, "lport", 0, "local port")
	flag.IntVar(&option.Count, "count", 3, "send times")

	flag.Parse()
	if len(flag.Args()) > 0 {
		fmt.Printf("unknown arguments: %+v\n", flag.Args())
		os.Exit(1)
	}

	ip := net.ParseIP(option.RemoteIP)
	if ip == nil {
		fmt.Printf("parse %s failed\n", os.Args[1])
		os.Exit(1)
	}

	fmt.Printf("local: %s:%d connect to: %s:%d\n",
		option.LocalIP, option.LocalPort, option.RemoteIP, option.RemotePort)
	srcAddr := &net.UDPAddr{IP: net.ParseIP(option.LocalIP), Port: option.LocalPort}
	dstAddr := &net.UDPAddr{IP: ip, Port: option.RemotePort}

	conn, err := net.DialUDP("udp", srcAddr, dstAddr)
	if err != nil {
		fmt.Println(err)
	}
	defer conn.Close()
	for i := 0; i < option.Count; i++ {
		conn.Write([]byte("hello"))
		data := make([]byte, 1024)
		n, err := conn.Read(data)
		if err != nil {
			fmt.Printf("read from <%s>: %s\n", conn.RemoteAddr(), err)
			break
		} else {
			fmt.Printf("read %s from <%s>\n", data[:n], conn.RemoteAddr())
		}
		time.Sleep(1 * time.Second)
	}
}

func SetGroups() {
	if err := syscall.Setgid(3003); err != nil {
		fmt.Printf("setgdi failed: %s\n", err)
	}
	gids := []int{3003, 3004, 3005, 3006, 3007, 3008}
	if err := syscall.Setgroups(gids); err != nil {
		fmt.Printf("setgroups failed: %s\n", err)
	}
}
