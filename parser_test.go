package main

import (
	"testing"

	"github.com/fsnotify/fsnotify"
)

func TestEventParser(t *testing.T) {
	tests := []struct {
		input    string
		expected fsnotify.Op
	}{
		{"create", fsnotify.Create},
		{"write", fsnotify.Write},
		{"remove", fsnotify.Remove},
		{"rename", fsnotify.Rename},
		{"chmod", fsnotify.Chmod},
	}

	for _, test := range tests {
		op := parseEvent(test.input)
		if op != test.expected {
			t.Errorf("For input %q, expected %v but got %v", test.input, test.expected, op)
		}
	}
}
