//
//  Generated code. Do not modify.
//  source: grpc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use lookupRequestDescriptor instead')
const LookupRequest$json = {
  '1': 'LookupRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `LookupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lookupRequestDescriptor = $convert.base64Decode(
    'Cg1Mb29rdXBSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use tokenSyncRequestDescriptor instead')
const TokenSyncRequest$json = {
  '1': 'TokenSyncRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `TokenSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenSyncRequestDescriptor = $convert.base64Decode(
    'ChBUb2tlblN5bmNSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdG9rZW4YAiABKAlSBX'
    'Rva2Vu');

@$core.Deprecated('Use queueRequestDescriptor instead')
const QueueRequest$json = {
  '1': 'QueueRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 3, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `QueueRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queueRequestDescriptor = $convert.base64Decode(
    'CgxRdWV1ZVJlcXVlc3QSEgoEbmFtZRgBIAMoCVIEbmFtZQ==');

