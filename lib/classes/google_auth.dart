import 'dart:math';

import 'package:SMI/classes/smi_userid_and_type.dart';
import 'package:SMI/classes/smi_token_exchange.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:SMI/chat/src/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:print_color/print_color.dart';
import 'package:SMI/chat/src/get_notifications.dart';
import '../chat/src/firebase_chat_core.dart';

class LoginController extends GetxController {
  var _googleSignin = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);
  var googleAuth = Rx<GoogleSignInAuthentication?>(null);

  //
  // login() async {
  //   googleAccount.value = await _googleSignin.signIn();

  // }

  logout() async {
    googleAccount.value = await _googleSignin.signOut();
  }

  login() async {
    googleAccount.value = await _googleSignin.signIn();
    final GoogleSignInAccount? googleUser = await _googleSignin.signIn();
    googleAuth.value = await googleUser!.authentication;

    String? serverAuthToken = googleUser.serverAuthCode;
    String? idToken = googleAuth.value!.idToken;
    String? accessToken = googleAuth.value!.accessToken;
    String? email = googleUser.email;

    Print.red(
        "Google serverAuthToken: $serverAuthToken"); //https://github.com/flutter/flutter/issues/97376#issuecomment-1024141072
    Print.red("Google idToken: $idToken");
    Print.red("Google accessToken: $accessToken");
    Print.red("Google email: $email");

    //final smiToken = Get.put(SmiToken());
    await Firebase.initializeApp();
    final storage = await FirebaseStorage.instance;

    FirebaseAuth _auth = FirebaseAuth.instance;
    // final response = await http.post(Uri.parse(
    Future<User> currentUser() async {
      final GoogleSignInAccount? googleUser = await _googleSignin.signIn();
      final GoogleSignInAuthentication authentication =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken, accessToken: accessToken);

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user!;
      return user;
    }

    await currentUser(); //Wait the current user data Firebase
    //await smiToken.get();
    final fcmToken =
        await FirebaseMessaging.instance.getToken(); //Firebase token

    final smiUserIdAndType = Get.put(SmiUserIdAndType());
    var smiId = smiUserIdAndType.smiUserId.value;
    var smiRole = smiUserIdAndType.smiUserType.value; //Wait the SMI Token
    User? firebaseUser = await FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      var isdocexists = false;
      try {
        var docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        isdocexists = (await docRef).exists;
      } catch (e) {
        Print.red(e);
      }
      //Check if the user is already registered in Firestore Database if not, create a new document
      if (isdocexists == false) {
        print('HELLO ERROR HERE : ');
        await FirebaseChatCore.instance.createUserInFirestore(
          types.User(
            id: firebaseUser.uid,
            firstName: firebaseUser.displayName!.split(' ').first,
            lastName: firebaseUser.displayName!.split(' ').last,
            imageUrl: firebaseUser.photoURL,
          ),
        );

        try {
          var docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set(
            {
              'smiUserId': '$smiId',
              'smiRole': '$smiRole',
              'firebaseToken': '$fcmToken',
              'highScore': 0,
            },
            SetOptions(merge: true),
          );
        } catch (e) {
          Print.red(e);
        }
      } else {
        try {
          var docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set(
            {
              'firebaseToken': '$fcmToken',
            },
            SetOptions(merge: true),
          );
        } catch (e) {
          Print.red(e);
        }
      }
    }

    String formatBytes(int bytes, int decimals) {
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      var i = (log(bytes) / log(1024)).floor();
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
          ' ' +
          suffixes[i];
    }

    final storageRef = FirebaseStorage.instance.ref().child("/");
    final listResult = await storageRef.listAll();
    var allsize = 0;
    for (var item in listResult.items) {
      // The items under storageRef
      printInfo();

      var itemdata = await item.getMetadata();

      allsize += itemdata.size!;
    }
    Print.cyan(formatBytes(allsize, 0));
    await setUpInteractedMessage();
  }
}
