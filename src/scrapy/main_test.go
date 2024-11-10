package main

import (
	"context"
	"crypto/x509"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"log"
	"os"
	pb "scrapy/protobuf"
	"testing"
)

func TestIssueRequest(t *testing.T) {
	pemServerCA, err := os.ReadFile("/ca.crt")

	if err != nil {
		log.Fatalf("Error loading CA cert: %v", err.Error())
	}

	certPool := x509.NewCertPool()

	if !certPool.AppendCertsFromPEM(pemServerCA) {
		log.Fatal("Failed to add CA's cert")
	}

	conn, err := grpc.NewClient("fcm-service:5551", grpc.WithTransportCredentials(credentials.NewClientTLSFromCert(certPool, "fcm-service")))

	if err != nil {
		panic(err)
	}

	grpcClient := pb.NewQueueRequestServiceClient(conn)

	defer conn.Close()

	result, err := grpcClient.Queue(context.Background(), &pb.QueueRequest{Name: []string{"ddffdfd"}})

	if err != nil {
		panic(err)
	}

	println("recvd", result.String())
}
