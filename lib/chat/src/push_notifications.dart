import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:http/http.dart' as http;

//final messages = FirebaseFirestore.instance.collection('users').doc('asd').collection('messages');

//Send Confirmation Message to User
sendNotificationToDirectUser(
    String senderName, String current_room, String sendToToken) async {
  //Our API Key
  var serverKey =
      "INSERTAPIKEYHERE";

  //Get our Admin token from Firesetore DB
  var token = sendToToken;
  //Create Message with Notification Payload
  String constructFCMPayload(String token) {
    return jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': "You have a new message from : $senderName",
          'title': "St.Martins Institute of higher education",
        },
        'data': <String, dynamic>{'chat_room': current_room},
        'to': token
      },
    );
  }

  if (token.isEmpty) {
    return log('Unable to send FCM message, no token exists.');
  }

  try {
    //Send  Message
    http.Response response =
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=$serverKey',
            },
            body: constructFCMPayload(token));

    log("status: ${response.statusCode} | Message Sent Successfully!");
    log("body : " + response.body);
    log("headers : " + response.headers.toString());
  } catch (e) {
    log("error push notification $e");
  }
}

sendNotificationToGroupUsers(String senderName, String current_group_room,
    List<String> groupTokens) async {
  //Our API Key
  var serverKey =
      "INSERTAPIKEYHERE";

  //Get our Admin token from Firesetore DB
  List<String> group_tokens = groupTokens;
  //Create Message with Notification Payload
  String constructFCMPayload(List<String> group_tokens) {
    return jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': "You have a new group message from : $senderName",
          'title': "St.Martins Institute of higher education",
        },
        'data': <String, dynamic>{'chat_room': current_group_room},
        'registration_ids': group_tokens
      },
    );
  }

  if (group_tokens.isEmpty) {
    return log('Unable to send FCM message, no token exists.');
  }

  try {
    //Send  Message
    http.Response response =
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=$serverKey',
            },
            body: constructFCMPayload(group_tokens));

    log("status: ${response.statusCode} | Message Sent Successfully!");
    log("body : " + response.body);
    log("headers : " + response.headers.toString());
  } catch (e) {
    log("error push notification $e");
  }
}
