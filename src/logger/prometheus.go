//go:build prometheus
// +build prometheus

package logger

import (
	"github.com/prometheus/client_golang/prometheus"
)

var (
	logCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "log_messages_total",
			Help: "Total number of log messages",
		},
		[]string{"level"},
	)
)

func init() {
	prometheus.MustRegister(logCounter)
}

func (p Logger) Log(message string) {
	logCounter.WithLabelValues("info").Inc()
	// Here you might want to push logs to an external system as well
}
