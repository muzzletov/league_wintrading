//
//  Generated code. Do not modify.
//  source: grpc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/empty.pb.dart' as $1;
import 'grpc.pb.dart' as $0;

export 'grpc.pb.dart';

@$pb.GrpcServiceName('protobuf.LookupRequestService')
class LookupRequestServiceClient extends $grpc.Client {
  static final _$lookup = $grpc.ClientMethod<$0.LookupRequest, $1.Empty>(
      '/protobuf.LookupRequestService/Lookup',
      ($0.LookupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));
  static final _$setToken = $grpc.ClientMethod<$0.TokenSyncRequest, $1.Empty>(
      '/protobuf.LookupRequestService/SetToken',
      ($0.TokenSyncRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));

  LookupRequestServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.Empty> lookup($0.LookupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$lookup, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> setToken($0.TokenSyncRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setToken, request, options: options);
  }
}

@$pb.GrpcServiceName('protobuf.LookupRequestService')
abstract class LookupRequestServiceBase extends $grpc.Service {
  $core.String get $name => 'protobuf.LookupRequestService';

  LookupRequestServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LookupRequest, $1.Empty>(
        'Lookup',
        lookup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LookupRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TokenSyncRequest, $1.Empty>(
        'SetToken',
        setToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TokenSyncRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> lookup_Pre($grpc.ServiceCall call, $async.Future<$0.LookupRequest> request) async {
    return lookup(call, await request);
  }

  $async.Future<$1.Empty> setToken_Pre($grpc.ServiceCall call, $async.Future<$0.TokenSyncRequest> request) async {
    return setToken(call, await request);
  }

  $async.Future<$1.Empty> lookup($grpc.ServiceCall call, $0.LookupRequest request);
  $async.Future<$1.Empty> setToken($grpc.ServiceCall call, $0.TokenSyncRequest request);
}
@$pb.GrpcServiceName('protobuf.QueueRequestService')
class QueueRequestServiceClient extends $grpc.Client {
  static final _$queue = $grpc.ClientMethod<$0.QueueRequest, $1.Empty>(
      '/protobuf.QueueRequestService/Queue',
      ($0.QueueRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));

  QueueRequestServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.Empty> queue($0.QueueRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queue, request, options: options);
  }
}

@$pb.GrpcServiceName('protobuf.QueueRequestService')
abstract class QueueRequestServiceBase extends $grpc.Service {
  $core.String get $name => 'protobuf.QueueRequestService';

  QueueRequestServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.QueueRequest, $1.Empty>(
        'Queue',
        queue_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.QueueRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> queue_Pre($grpc.ServiceCall call, $async.Future<$0.QueueRequest> request) async {
    return queue(call, await request);
  }

  $async.Future<$1.Empty> queue($grpc.ServiceCall call, $0.QueueRequest request);
}
