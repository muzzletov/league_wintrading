// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.5.1
// - protoc             v3.21.12
// source: cmd/protobuf/grpc.proto

package __

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
	emptypb "google.golang.org/protobuf/types/known/emptypb"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.64.0 or later.
const _ = grpc.SupportPackageIsVersion9

const (
	QueueRequestService_Queue_FullMethodName = "/protobuf.QueueRequestService/Queue"
)

// QueueRequestServiceClient is the client API for QueueRequestService service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type QueueRequestServiceClient interface {
	Queue(ctx context.Context, in *QueueRequest, opts ...grpc.CallOption) (*emptypb.Empty, error)
}

type queueRequestServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewQueueRequestServiceClient(cc grpc.ClientConnInterface) QueueRequestServiceClient {
	return &queueRequestServiceClient{cc}
}

func (c *queueRequestServiceClient) Queue(ctx context.Context, in *QueueRequest, opts ...grpc.CallOption) (*emptypb.Empty, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(emptypb.Empty)
	err := c.cc.Invoke(ctx, QueueRequestService_Queue_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// QueueRequestServiceServer is the server API for QueueRequestService service.
// All implementations must embed UnimplementedQueueRequestServiceServer
// for forward compatibility.
type QueueRequestServiceServer interface {
	Queue(context.Context, *QueueRequest) (*emptypb.Empty, error)
	mustEmbedUnimplementedQueueRequestServiceServer()
}

// UnimplementedQueueRequestServiceServer must be embedded to have
// forward compatible implementations.
//
// NOTE: this should be embedded by value instead of pointer to avoid a nil
// pointer dereference when methods are called.
type UnimplementedQueueRequestServiceServer struct{}

func (UnimplementedQueueRequestServiceServer) Queue(context.Context, *QueueRequest) (*emptypb.Empty, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Queue not implemented")
}
func (UnimplementedQueueRequestServiceServer) mustEmbedUnimplementedQueueRequestServiceServer() {}
func (UnimplementedQueueRequestServiceServer) testEmbeddedByValue()                             {}

// UnsafeQueueRequestServiceServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to QueueRequestServiceServer will
// result in compilation errors.
type UnsafeQueueRequestServiceServer interface {
	mustEmbedUnimplementedQueueRequestServiceServer()
}

func RegisterQueueRequestServiceServer(s grpc.ServiceRegistrar, srv QueueRequestServiceServer) {
	// If the following call pancis, it indicates UnimplementedQueueRequestServiceServer was
	// embedded by pointer and is nil.  This will cause panics if an
	// unimplemented method is ever invoked, so we test this at initialization
	// time to prevent it from happening at runtime later due to I/O.
	if t, ok := srv.(interface{ testEmbeddedByValue() }); ok {
		t.testEmbeddedByValue()
	}
	s.RegisterService(&QueueRequestService_ServiceDesc, srv)
}

func _QueueRequestService_Queue_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueueRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueueRequestServiceServer).Queue(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: QueueRequestService_Queue_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueueRequestServiceServer).Queue(ctx, req.(*QueueRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// QueueRequestService_ServiceDesc is the grpc.ServiceDesc for QueueRequestService service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var QueueRequestService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "protobuf.QueueRequestService",
	HandlerType: (*QueueRequestServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Queue",
			Handler:    _QueueRequestService_Queue_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "cmd/protobuf/grpc.proto",
}
