import 'package:SMI/chat/views/group_chat_view.dart';
import 'package:SMI/chat/views/group_users_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'group_chat_view.dart';
import '../../firebase_options.dart';
import 'group_users_view.dart';
import 'chat_views_util.dart';

//Group Messages Overview

class GroupRooms extends StatefulWidget {
  const GroupRooms({super.key});

  @override
  State<GroupRooms> createState() => _GroupRoomPageState();
}

class _GroupRoomPageState extends State<GroupRooms> {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  var group_room_count = 0;
  bool _error = false;
  bool _initialized = false;
  User? _user;

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0, //removes shadow
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: const Text(
          'Group Messages',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _user == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const GroupUsersPage(),
                      ),
                    );
                  },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ),
      body: _user == null
          ? Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not authenticated'),
                  TextButton(
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     fullscreenDialog: true,
                      //     builder: (context) => GoogleLoginView(),
                      //   ),
                      // );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<types.Room>>(
              stream: FirebaseChatCore.instance.rooms(),
              initialData: const [],
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                      bottom: 200,
                    ),
                    child: const Text('No rooms'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];
                    if (room.type == types.RoomType.group) {
                      group_room_count++;
                      List userIdsList = [];
                      return GestureDetector(
                        onLongPress: () async => {
                          HapticFeedback.vibrate(),
                          await FirebaseFirestore.instance
                              .collection('rooms')
                              .doc(room.id)
                              .get()
                              .then((value) {
                            List userIds = value.data()!['userIds'];
                            print(userIds);
                            userIdsList.addAll(userIds);
                          }),
                          print(userIdsList[0]),
                          if (userIdsList[0] == firebaseUser!.uid)
                            {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Group'),
                                  content: const Text(
                                      'Are you sure you want to delete this group?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseChatCore.instance
                                            .deleteRoom(room.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            }
                          else
                            {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Leave Group'),
                                  content: const Text(
                                      'Are you sure you want to leave this group?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('rooms')
                                            .doc(room.id)
                                            .update({
                                          'userIds': FieldValue.arrayRemove(
                                              [firebaseUser!.uid])
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Leave'),
                                    ),
                                  ],
                                ),
                              ),
                            }
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupChatPage(
                                room: room,
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              width: screenWidth,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      10.0), //round corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      //spreadRadius: 5,
                                      blurRadius: 3,
                                      offset: const Offset(
                                          1, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    // _buildAvatar(room),
                                    IconButton(
                                      icon: const Icon(Icons.group),
                                      onPressed: () {},
                                    ),
                                    Text(
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        room.name ?? ''),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      if (group_room_count < 1) {
                        print('Number : ' + group_room_count.toString());
                        return Container();
                      } else {
                        print('Number : ' + group_room_count.toString());
                        return Container();
                      }
                    }
                  },
                );
              },
            ),
    );
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        setState(() {
          _user = user;
        });
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _buildAvatar(types.Room room) {
    var color = Colors.transparent;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
          (u) => u.id != _user!.uid,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found.
      }
    }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }
}
