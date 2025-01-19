package main

import (
	"flag"
	"log"
	"path/filepath"
	"strings"

	"github.com/fsnotify/fsnotify"
	"github.com/gen2brain/beeep"
)

func handleEvent(event fsnotify.Event, prefixes []string, events fsnotify.Op) {
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
}

func watchDirectory(watcher *fsnotify.Watcher, prefixes []string, events fsnotify.Op) {
	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			handleEvent(event, prefixes, events)
		case err, ok := <-watcher.Errors:
			if !ok {
				return
			}
			log.Println("error:", err)
		}
	}
}

func main() {
	dirPtr := flag.String("dir", "/dev", "a directory")
	prefixPtr := flag.String("prefix", "tty", "a comma-separated list of prefixes")
	eventPtr := flag.String("event", "chmod,create,remove,rename,write", "a comma-separated list of events")

	flag.Parse()
	log.Println("dir:", *dirPtr)
	log.Println("event:", *eventPtr)
	log.Println("prefix:", *prefixPtr)

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
	watchDirectory(watcher, prefixes, events)
}
