module scrapy

go 1.23.2

replace shared => ../shared

replace middleware => ../middleware

replace logger => ../logger

require (
	github.com/valkey-io/valkey-go v1.0.47
	google.golang.org/grpc v1.67.1
	google.golang.org/protobuf v1.35.1
	logger v0.0.0-00010101000000-000000000000
	middleware v0.0.0-00010101000000-000000000000
	shared v0.0.0-00010101000000-000000000000
)

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/cilium/ebpf v0.16.0 // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/muzzletov/parseur v0.0.0-20241110143032-5aeb5e1c9339 // indirect
	github.com/prometheus/client_golang v1.20.5 // indirect
	github.com/prometheus/client_model v0.6.1 // indirect
	github.com/prometheus/common v0.55.0 // indirect
	github.com/prometheus/procfs v0.15.1 // indirect
	golang.org/x/exp v0.0.0-20240719175910-8a7402abbf56 // indirect
	golang.org/x/net v0.30.0 // indirect
	golang.org/x/sys v0.26.0 // indirect
	golang.org/x/text v0.19.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20241015192408-796eee8c2d53 // indirect
)
