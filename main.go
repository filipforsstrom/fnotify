package main

import (
	"flag"
	"fmt"
	"log"
	"path/filepath"
	"strings"

	"github.com/fsnotify/fsnotify"
	"github.com/gen2brain/beeep"
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
	eventsStrings := strings.Split(*eventPtr, ",")

	var events fsnotify.Op
	for _, eventString := range eventsStrings {
		events |= parseEvent(eventString)
	}

	// Create new watcher.
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer watcher.Close()

	// Add the directory.
	err = watcher.Add(dir)
	if err != nil {
		log.Fatal(err)
	}

	// Start listening for events.
	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			for _, prefix := range prefixes {
				if strings.HasPrefix(filepath.Base(event.Name), prefix) && event.Op&events != 0 {
					log.Println("event:", event)
					err := beeep.Notify("New file event", event.String(), "assets/information.png")
					if err != nil {
						panic(err)
					}
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
}
