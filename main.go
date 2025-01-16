package main

import (
	"flag"
	"fmt"
	"log"
	"path/filepath"
	"strings"

	"github.com/fsnotify/fsnotify"
)

func main() {
	dirPtr := flag.String("dir", "/dev", "a directory")
	prefixPtr := flag.String("prefix", "tty", "a comma-separated list of prefixes")
	eventPtr := flag.String("event", "chmod,create,remove,rename,write", "a comma-separated list of events")

	flag.Parse()
	fmt.Println("dir:", *dirPtr)
	fmt.Println("event:", *eventPtr)
	fmt.Println("prefix:", *prefixPtr)

	dir := *dirPtr
	prefixes := strings.Split(*prefixPtr, ",")
	events := strings.Split(*eventPtr, ",")

	// Create new watcher.
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer watcher.Close()

	// Start listening for events.
	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				for _, prefix := range prefixes {
					if strings.HasPrefix(filepath.Base(event.Name), prefix) && event.Has(fsnotify.Create) {
						log.Println("event:", event)
						break
					}
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Println("error:", err)
			}
		}
	}()

	// Add the directory.
	err = watcher.Add(dir)
	if err != nil {
		log.Fatal(err)
	}

	// Block main goroutine forever.
	<-make(chan struct{})
}
