package main

import (
	"context"
	__ "fcm/protobuf"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"fmt"
	"github.com/valkey-io/valkey-go"
	"google.golang.org/api/option"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/types/known/emptypb"
	"log"
	"middleware"
	"net"
	"os"
	"shared"
	"sync"
	"time"
)

type QueueRequestServiceServer struct {
	__.UnimplementedQueueRequestServiceServer
}

var vkeyClient valkey.Client
var queue shared.Queue
var client *messaging.Client

func processQueue() {
	tokens := queue.Pop()

	message := messaging.MulticastMessage{Notification: &messaging.Notification{
		Title: "WinTrading Request",
		Body:  "Someone on the opposite team requested a win trade",
	}, Tokens: tokens}

	br, err := client.SendEachForMulticast(context.Background(), &message)

	if err != nil {
		log.Fatalln(err)
	}

	if br.FailureCount > 0 {
		var failedTokens []string
		for idx, resp := range br.Responses {
			if !resp.Success {
				failedTokens = append(failedTokens, tokens[idx])
			}
		}

		log.Printf("List of tokens that caused failures: %v\n", failedTokens)
	}
}

func initFCM() {
	projectId, ok := os.LookupEnv("FCM_PROJECT_ID")

	if !ok {
		log.Fatal("FCM project id environment variable not set")
	}

	ctx := context.Background()
	opt := option.WithCredentialsFile("credentials.json")
	config := &firebase.Config{ProjectID: projectId}
	app, err := firebase.NewApp(ctx, config, opt)

	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	client, err = app.Messaging(ctx)

	if err != nil {
		log.Fatalf("failed to load FCM client: %v", err)
	}
}

func initGRPCService() {

	host, hostOk := os.LookupEnv("FCM_APP_HOST")
	port, portOk := os.LookupEnv("FCM_APP_PORT")

	if !portOk || !hostOk {
		log.Fatal("GRPC Port and hostname environment variables are mandatory")
	}

	endpoint := fmt.Sprintf("%s:%s", host, port)
	lis, err := net.Listen("tcp", endpoint)

	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	config, _ := credentials.NewServerTLSFromFile("cert/tls.crt", "cert/tls.key")
	grpcServer := grpc.NewServer(grpc.Creds(config), grpc.UnaryInterceptor(middleware.GRPCServerInterceptor()))

	__.RegisterQueueRequestServiceServer(grpcServer, &QueueRequestServiceServer{})

	err = grpcServer.Serve(lis)

	if err != nil {
		log.Fatalf("gprc exited abnormally: %v", err)
	}
}

func main() {
	queue = shared.Queue{
		Mu:        sync.Mutex{},
		Array:     make([]string, 0),
		Debouncer: shared.NewDebouncer(processQueue, 250*time.Millisecond, 2*time.Second),
	}

	vkeyClient = shared.ConnectValkey()
	initFCM()
	initGRPCService()
}

func (c *QueueRequestServiceServer) Queue(ctx context.Context, request *__.QueueRequest) (*emptypb.Empty, error) {
	result := vkeyClient.Do(ctx, vkeyClient.B().Mget().Key(request.GetName()...).Build())
	var err = result.NonValkeyError()

	if err != nil {
		log.Printf("failed to load query tokens: %v\n", err)
		return nil, nil
	}

	err = result.Error()

	if err != nil {
		log.Printf("failed to load query tokens: %v\n", err)
		return nil, nil
	}

	tokens, err := result.AsStrSlice()

	if err != nil {
		log.Printf("failed to load query tokens: %v\n", err)
		return nil, nil
	}

	tokensAsString := make([]string, 0)

	for _, token := range tokens {
		if token == "" {
			continue
		}

		tokensAsString = append(tokensAsString, token)
	}

	if len(tokensAsString) > 0 {
		queue.Put(tokensAsString)
	} else {
		log.Println("no tokens found")
	}

	return nil, nil
}
