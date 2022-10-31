import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'direct_chat_view.dart';
import '../../firebase_options.dart';
import 'direct_users_view.dart';
import 'chat_views_util.dart';

//Direct Messages Overview

class DirectMessagesView extends StatefulWidget {
  const DirectMessagesView({super.key});

  @override
  State<DirectMessagesView> createState() => _DirectMessagesViewState();
}

class _DirectMessagesViewState extends State<DirectMessagesView> {
  var room_count = 0;
  bool _error = false;
  bool _initialized = false;
  User? _user;

  //Initialize search variables
  bool _searchBoolean = false; //add search view switch boolean operator
  List<int> _searchIndexList = []; //add
  List searchdirect_initial = []; // add search list user arrays
  Set searchdirectrooms = {}; //add search list usernames

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

        title: !_searchBoolean
            ? Text("Direct Messages",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
            : _searchTextField(),
        actions: !_searchBoolean
            ? [
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = true;
                        _searchIndexList = [];
                      });
                    }),
              ]
            : [
                IconButton(
                    icon: Icon(Icons.refresh_outlined),
                    onPressed: () {
                      setState(() {
                        _searchBoolean = false;
                        _searchIndexList = [];
                      });
                    }),
              ],
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: _user == null
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const directUsersPage(),
                    ),
                  );
                },
        ),
      ),
      body: !_searchBoolean ? roomsList() : searchRoomsList(),
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

  Widget _searchTextField() {
    //add
    return TextField(
      autofocus: true, //Display the keyboard when TextField is displayed
      cursorColor: Theme.of(context).primaryColor,
      style: const TextStyle(
        fontSize: 20,
      ),
      textInputAction:
          TextInputAction.search, //Specify the action button on the keyboard
      decoration: const InputDecoration(
        //Style of TextField
        enabledBorder: UnderlineInputBorder(
            //Default TextField border
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(
            //Borders when a TextField is in focus
            borderSide: BorderSide(color: Colors.white)),
        hintText: 'Search', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle(
          //Style of hintText
          fontSize: 20,
        ),
      ),
      onChanged: (String s) {
        //add
        setState(() {
          _searchIndexList = [];
          for (int i = 0; i < searchdirectrooms.toList().length; i++) {
            if (searchdirectrooms.toList()[i].contains(s)) {
              _searchIndexList.add(i);
            }
          }
        });
        print('s String : $s');
        print("searchdirect_initial : $searchdirectrooms");

        print("searchIndexList: $_searchIndexList");
      },
    );
  }

  Widget roomsList() {
    return _user == null
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
                  onPressed: () {},
                  child: const Text('Login'),
                ),
              ],
            ),
          )
        : StreamBuilder<List<types.Room>>(
            stream: FirebaseChatCore.instance.rooms(),
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text('ERROR');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              // if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //   return Container(
              //     alignment: Alignment.center,
              //     margin: const EdgeInsets.only(
              //       bottom: 200,
              //     ),
              //     child: const CircularProgressIndicator(),
              //   );
              // }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final room = snapshot.data![index];
                  searchdirect_initial.add(room);
                  searchdirectrooms.add(room.name);
                  if (room.type == types.RoomType.direct) {
                    room_count++;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              room: room,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius:
                              BorderRadius.circular(10.0), //round corners
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              //spreadRadius: 5,
                              blurRadius: 3,
                              offset: const Offset(
                                  1, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            _buildAvatar(room),
                            Text(room.name ?? ''),
                          ],
                        ),
                      ),
                    );
                  } else if (room_count < 1) {
                    return Container();
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
  }

  Widget searchRoomsList() {
    return _user == null
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
                  onPressed: () {},
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
                  child: const CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                itemCount: _searchIndexList.length,
                itemBuilder: (context, index) {
                  index = _searchIndexList[index];
                  final room = snapshot.data![index];
                  if (room.type == types.RoomType.direct) {
                    room_count++;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              room: room,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius:
                              BorderRadius.circular(10.0), //round corners
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              //spreadRadius: 5,
                              blurRadius: 3,
                              offset: const Offset(
                                  1, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            _buildAvatar(room),
                            Text(room.name ?? ''),
                          ],
                        ),
                      ),
                    );
                  } else if (room_count < 1) {
                    return Container();
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
  }
}
