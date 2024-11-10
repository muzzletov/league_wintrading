//go:build console
// +build console

package logger

import "fmt"

func (c Logger) Log(message string) {
	fmt.Println("Log:", message)
}
