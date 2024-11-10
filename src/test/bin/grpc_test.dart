import 'dart:io';
import 'package:grpc/grpc.dart';
import 'package:test/src/generated/grpc.pbgrpc.dart';

Future<void> main(List<String> args) async {
  if (args.length == 0) {
    print("provide a name");
    return;
  }

  final name = args[0];
  final cert = File('scp.crt').readAsBytesSync();
  final channel = ClientChannel(
    'scp-service',
    port: 5552,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(certificates: cert,
        )),
  );

  try {
    await LookupRequestServiceClient(channel).setToken(
        TokenSyncRequest(name: "ass", token: "wipe"));
    print(
        "Successfully stored key 'ass' and value 'wipe'!\nYou're all set up.");
  } catch (e) {
    print('Caught error: $e');
  }


  await channel.shutdown();
}