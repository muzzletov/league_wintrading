package main

import (
	"context"
	"crypto/x509"
	"fmt"
	"github.com/valkey-io/valkey-go"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/types/known/emptypb"
	"log"
	"logger"
	"middleware"
	"net"
	_ "net/http/pprof"
	"os"
	pb "scrapy/protobuf"
	"scrapy/scraper"
	"shared"
	"sync"
	"time"
)

var vkeyClient valkey.Client
var queue shared.Queue
var l logger.Logger
var scrapy = scraper.NewScraper()

type LookupRequestServiceServer struct {
	pb.UnimplementedLookupRequestServiceServer
}

type Client struct {
	conn       *grpc.ClientConn
	grpcClient pb.QueueRequestServiceClient
	mu         sync.Mutex
}

var client *Client

func NewClient() *Client {
	host, hostOk := os.LookupEnv("FCM_APP_HOST")
	port, portOk := os.LookupEnv("FCM_APP_PORT")

	if !portOk || !hostOk {
		log.Fatal("Client GRPC Port and hostname environment variables are mandatory")
	}

	pemServerCA, err := os.ReadFile("ca.crt")

	if err != nil {
		log.Fatalf("Error loading CA cert: %v", err.Error())
	}

	certPool := x509.NewCertPool()

	if !certPool.AppendCertsFromPEM(pemServerCA) {
		log.Fatal("Failed to add CA's cert")
	}

	client := Client{}
	endpoint := fmt.Sprintf("%s:%s", host, port)

	client.conn, err = grpc.NewClient(endpoint, grpc.WithTransportCredentials(credentials.NewClientTLSFromCert(certPool, "fcm-service")), grpc.WithUnaryInterceptor(middleware.GRPCClientInterceptor()))

	if err != nil {
		panic(err)
	}

	client.grpcClient = pb.NewQueueRequestServiceClient(client.conn)

	return &client
}

func initGRPCService() {
	host, hostOk := os.LookupEnv("SCP_APP_HOST")
	port, portOk := os.LookupEnv("SCP_APP_PORT")

	if !portOk || !hostOk {
		log.Fatal("GRPC Port and hostname environment variables are mandatory")
	}

	lis, err := net.Listen("tcp", fmt.Sprintf("%s:%s", host, port))

	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	creds, err := credentials.NewServerTLSFromFile("cert/tls.crt", "cert/tls.key")

	if err != nil {
		log.Fatalf("failed to create server: %v", err)
	}

	grpcServer := grpc.NewServer(grpc.Creds(creds))

	pb.RegisterLookupRequestServiceServer(grpcServer, &LookupRequestServiceServer{})

	err = grpcServer.Serve(lis)

	if err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func processQueue() {
	names := queue.Pop()
	result, err := client.grpcClient.Queue(context.Background(), &pb.QueueRequest{Name: names}, grpc.WaitForReady(true))

	if err != nil {
		println(err.Error())
	} else {
		println(result.String())
	}
}

func main() {
	queue = shared.Queue{
		Mu:        sync.Mutex{},
		Array:     make([]string, 0),
		Debouncer: shared.NewDebouncer(processQueue, 250*time.Millisecond, time.Second),
	}

	vkeyClient = shared.ConnectValkey()
	client = NewClient()

	defer func(conn *grpc.ClientConn) {
		err := conn.Close()
		if err != nil {
			log.Fatalf("closing the connection failed: %v", err)
		}
	}(client.conn)

	initGRPCService()

}

func (q *LookupRequestServiceServer) Lookup(_ context.Context, request *pb.LookupRequest) (*emptypb.Empty, error) {
	names := scrapy.FetchAndParse(request.GetName())

	if names != nil {
		// TODO: PREVENT THRASHING
		go queue.Put(*names)
	} else {
		log.Print("array is nil")
	}

	return nil, nil
}

func (q *LookupRequestServiceServer) SetToken(ctx context.Context, request *pb.TokenSyncRequest) (*emptypb.Empty, error) {
	err := vkeyClient.Do(ctx, vkeyClient.B().Set().Key(request.GetName()).Value(request.GetToken()).Build()).Error()
	return nil, err
}
