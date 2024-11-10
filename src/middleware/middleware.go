package middleware

import (
	"context"
	"github.com/google/uuid"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

func GRPCServerInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (resp interface{}, err error) {
		data, ok := metadata.FromIncomingContext(ctx)
		var correlationID string

		if ok && len(data.Get("x-correlation-id")) > 0 {
			correlationID = data.Get("x-correlation-id")[0]
		} else {
			correlationID = uuid.New().String()
		}

		return handler(context.WithValue(ctx, "correlation-id", correlationID), req)
	}
}

func GRPCClientInterceptor() grpc.UnaryClientInterceptor {
	return func(
		ctx context.Context,
		method string,
		req, reply interface{},
		cc *grpc.ClientConn,
		invoker grpc.UnaryInvoker,
		opts ...grpc.CallOption,
	) error {
		var correlationID string

		val := ctx.Value("correlation-id")

		if val != nil {
			correlationID = ctx.Value("correlation-id").(string)
		} else {
			correlationID = uuid.New().String()
		}

		data := metadata.Pairs("x-correlation-id", correlationID)

		return invoker(metadata.NewOutgoingContext(ctx, data), method, req, reply, cc, opts...)
	}
}
