import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:print_color/print_color.dart';
import '../views/direct_chat_view.dart';

//Set up navigatorkey for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//Set up future for background message handling
Future<void> setUpInteractedMessage() async {
  Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  ///Configure notification permissions
  //IOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  //Android
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  log('User granted permission: ${settings.authorizationStatus}');

  //Get the message from tapping on the notification when app is not in foreground
  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  _mapMessageToUser(RemoteMessage message) async {
    Map<String, dynamic> json = message.data;
    var current_room = message.data['chat_room'];
    //Print.green("Here is the ID : $current_room");
    if (message.data['chat_room'] != null) {
      var current_room = message.data['chat_room'];

      Map<String, dynamic> room_decode = jsonDecode(current_room);
      final roomhere = Room.fromJson(room_decode);
      Print.cyan(roomhere);
      // Room currentRoomHere = Room.fromJson(json['chat_room']);
      try {
        Print.red("Open current conversation's view");
        final navigator = Navigator.of(navigatorKey.currentContext!);
        navigator.pop();
        await navigator.push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              room: roomhere,
            ),
          ),
        );
      } catch (e) {
        Print.red("Error in navigating to room $e");
      }
    }
  }

  //If the message contains a service, navigate to the admin
  if (initialMessage != null) {
    await _mapMessageToUser(initialMessage);
  }

  //This listens for messages when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen(_mapMessageToUser);

  //Listen to messages in Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    //Initialize FlutterLocalNotifications
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'schedular_channel', // id
      'Schedular Notifications', // title
      description:
          'This channel is used for Schedular app notifications.', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    //Construct local notification using our created channel
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: "@mipmap/ic_launcher", //Your app icon goes here
              // other properties...
            ),
          ));
    }
  });
}
