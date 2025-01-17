package main

import (
	"strings"

	"github.com/fsnotify/fsnotify"
)

func parseEvent(event string) fsnotify.Op {
	switch strings.ToLower(event) {
	case "create":
		return fsnotify.Create
	case "write":
		return fsnotify.Write
	case "remove":
		return fsnotify.Remove
	case "rename":
		return fsnotify.Rename
	case "chmod":
		return fsnotify.Chmod
	}
	return fsnotify.Op(0)
}
