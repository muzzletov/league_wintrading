import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../firebase_options.dart';

import '../src/generated/grpc.pbgrpc.dart';

class FCMService {
  static String? token;
  static int? timestamp;
  static late bool updateFailed;

  static const IDENTIFIER_TOKEN = "TOKEN";
  static const IDENTIFIER_NAME = "SUMMONER_NAME";
  static const IDENTIFIER_TIMESTAMP = "TIMESTAMP";

  static const IDENTIFIER_UPDATE_FAILED = "UPDATE_FAILED";
  static final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static get messengerKey => _scaffoldMessengerKey;

  static late final ClientChannel channel;

  FCMService._internal();

  static Future<void> cleanup() async {
    await channel.shutdown();
  }

  @pragma('vm:entry-point')
  static void validityTask() {
      Workmanager().executeTask((task, inputData) async {
        syncToken(await FirebaseMessaging.instance.getToken());
        return true;
      });
  }

  static void scheduleValidityCheck() {
    final Workmanager wm = Workmanager();

    wm.initialize(
      validityTask,
      isInDebugMode: true,
    );

    wm.registerPeriodicTask(
      "1",
      "simplePeriodicTask",
      initialDelay: const Duration(days: 3),
      frequency: const Duration(days: 3), // Minimum interval
    );
  }

  static updateToken(currentToken) async {
    final prefs = await SharedPreferences.getInstance();
    final summonerName = prefs.getString(IDENTIFIER_NAME);

    bool success = false;
    token = currentToken ?? await FirebaseMessaging.instance.getToken();

    prefs.setString(IDENTIFIER_TOKEN, token!);
    prefs.setInt(IDENTIFIER_TIMESTAMP, DateTime.now().millisecondsSinceEpoch);

    if (summonerName != null) {
        success = await syncRemote(summonerName, token);
    }

    updateFailed = await prefs.setBool(IDENTIFIER_UPDATE_FAILED, !success);

    return success;
  }

  static syncRemote(name, token) async {
    bool success = false;
    try {
      await LookupRequestServiceClient(channel).setToken(TokenSyncRequest(name: name, token: token));
      success = true;
    } catch (e) {
      log('Caught error: $e');
    }

    return success;
  }

  static syncToken(fcmToken) async {
    var shouldUpdate = fcmToken != token
        || timestamp == null
        || updateFailed
        || DateTime.now().millisecondsSinceEpoch + 17280000 > timestamp!;
    bool success = !shouldUpdate;
    if (shouldUpdate) success = await updateToken(fcmToken);

    return success;
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(IDENTIFIER_NAME);
  }

  static Future<void> issueRequest() async {
    try {
      await LookupRequestServiceClient(channel).lookup(LookupRequest(name: await getName()));
    } catch (e) {
      log('Caught error: $e');
    }
  }

  static Future<bool> setName(name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(IDENTIFIER_NAME, name);

    return await syncRemote(name, token);
  }

  static void showSnackbar(String message, {duration = 60 }) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Row(
      children: <Widget>[
      const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
          Text(message)
      ],
    ), behavior: SnackBarBehavior.floating, duration: Duration(seconds: duration),),
    );
  }

  static init() async {
    final ByteData bytes = await rootBundle.load('scp.crt');

    channel = ClientChannel(
    'scp-service',
    port: 5552,
    options: ChannelOptions(credentials: ChannelCredentials.secure(certificates: bytes.buffer.asUint8List())),
    );
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(IDENTIFIER_TOKEN);
    timestamp = prefs.getInt(IDENTIFIER_TIMESTAMP);
    updateFailed = prefs.getBool(IDENTIFIER_UPDATE_FAILED) ?? false;

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showSnackbar(message.notification!.body!);
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      if(!syncToken(fcmToken)) {
        showSnackbar("updating the token failed", duration: 3);
      }

    }).onError((err) {});

    syncToken(token);
  }
}
