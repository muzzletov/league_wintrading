package shared

import (
	"fmt"
	"github.com/valkey-io/valkey-go"
	"log"
	"os"
	"sync"
	"time"
)

type Queue struct {
	Mu        sync.Mutex
	Array     []string
	Debouncer Debouncer
}

func (q *Queue) Pop() []string {
	q.Mu.Lock()
	defer q.Mu.Unlock()

	limit := min(100, len(q.Array))
	a := q.Array[:limit]
	q.Array = q.Array[limit:]

	return a
}

func (q *Queue) Put(items []string) {
	q.Mu.Lock()
	q.Array = append(q.Array, items...)
	q.Mu.Unlock()
	q.Debouncer.Call()
}

func ConnectValkey() valkey.Client {
	redisHost, hostOk := os.LookupEnv("VKEY_HOST")
	redisPort, portOk := os.LookupEnv("VKEY_PORT")
	redisPass, passOk := os.LookupEnv("VKEY_PASSWORD")

	if !portOk || !hostOk || !passOk {
		log.Fatal("Password, port and hostname environment variables are mandatory")
	}

	addresses := []string{fmt.Sprintf("%s:%s", redisHost, redisPort)}
	client, _ := valkey.NewClient(valkey.ClientOption{
		InitAddress: addresses,
		Password:    redisPass,
	})

	return client
}

type Debouncer struct {
	mu        sync.Mutex
	timer     *time.Timer
	Timeout   time.Duration
	timestamp int64
	Threshold time.Duration
	Callback  func()
}

func (d *Debouncer) Call() {
	d.mu.Lock()
	defer d.mu.Unlock()

	if d.timer != nil {
		d.timer.Stop()
	} else {
		d.timestamp = time.Now().UnixMilli()
	}

	if d.Threshold.Milliseconds() < time.Now().UnixMilli()-d.timestamp {
		d.callback()
	} else {
		d.timer = time.AfterFunc(d.Timeout, d.callback)
	}
}

func (d *Debouncer) callback() {
	d.mu.Lock()
	defer d.mu.Unlock()

	if d.Callback != nil {
		d.Callback()
	}

	d.timer = nil
}

func NewDebouncer(process func(), duration time.Duration, threshold time.Duration) Debouncer {
	return Debouncer{Callback: process, Timeout: duration, mu: sync.Mutex{}, Threshold: threshold}
}
