import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../chat/views/chat_views_util.dart'; //for time formatting

class leaderBoardPage extends StatefulWidget {
  _leaderBoardPage createState() => _leaderBoardPage();
  const leaderBoardPage({super.key});
}

class _leaderBoardPage extends State<leaderBoardPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        elevation: 0, //removes shadow
        systemOverlayStyle: SystemUiOverlayStyle.dark,

        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          //  Pass Stream<QuerySnapshot> to stream
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('highScore', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              // Retrieve List<DocumentSnapshot> from snapshot
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView(
                  children: documents
                      .map((doc) => Card(
                            child: ListTile(
                              trailing: Text(doc['highScore'].toString()),
                              title: Text(
                                  doc['firstName'] + ' ' + doc['lastName']),
                              subtitle: Text('Highest Score : '),
                            ),
                          ))
                      .toList());
            } else if (snapshot.hasError) {
              return CircularProgressIndicator();
            } else {
              return CircularProgressIndicator();
            }
          }));
}
