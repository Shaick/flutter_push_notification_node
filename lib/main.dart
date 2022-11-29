import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notify_node/empty_page.dart';
import 'package:push_notify_node/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.instance.getToken().then((value) {
    debugPrint("getToken : $value");
  });

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  //if app is closed or terminated
  /*   FirebaseMessaging.instance.getInitialMessage().then(
        (RemoteMessage? message) {
          if (message != null) {
            Navigator.pushNamed(
              navigatorKey.currentState!.context,
              "/push-page",
              arguments: {"message", json.encode(message.data)},
            );
          }
        },
      ); */

  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      debugPrint("onMessageOpenedApp : $message");
      Navigator.pushNamed(
        navigatorKey.currentState!.context,
        '/push-page',
        arguments: {"message", json.encode(message.data)},
      );
    },
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> _handleMessage(RemoteMessage message) async {
  if (message.data.isNotEmpty) {
    Navigator.pushNamed(
      navigatorKey.currentState!.context,
      "/push-page",
      arguments: {"message", json.encode(message.data)},
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint("_firebaseMessagingBackgroundHandler: $message");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/home': ((context) => const EmptyPage()),
        '/push-page': ((context) => const HomePage()),
      },
      home: const EmptyPage(),
    );
  }
}
