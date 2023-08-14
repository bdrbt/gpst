package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
)

var (
	VERSION = "0.0.1"
	BUILD   = ""
)

func main() {
	log.Printf("service version:%s build:%s", VERSION, BUILD)

	// graceful shutdown on error or os signals
	errChan := make(chan error, 1)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	for {
		select {
		case err := <-errChan:
			if err != nil {
				log.Fatalf("Server error: %v", err)
			}

			os.Exit(-1)

		case <-sigChan:
			log.Print("service shutting down.\n")
			os.Exit(0)
		}
	}
}
