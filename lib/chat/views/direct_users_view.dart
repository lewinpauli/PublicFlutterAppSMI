import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart'; //for time formatting

import 'direct_chat_view.dart';
import 'chat_views_util.dart';

//Searching for Users in Direct Messages View

late List<String> directUsersNames = [];
late List<String> directUsersIds = [];
late List<types.User> directUsers_initial = [];

var name = "";
late List<bool> _isChecked;

class directUsersPage extends StatefulWidget {
  _directUsersPageState createState() => _directUsersPageState();
  const directUsersPage({super.key});
}

class _directUsersPageState extends State<directUsersPage> {
  //Initialize search variables
  bool _searchBoolean = false; //add search view switch boolean operator
  List<int> _searchIndexList = []; //add
  List searchdirect_initial = []; // add search list user arrays
  Set searchdirectusers = {}; //add search list usernames

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          directUsersNames.clear();
          directUsersIds.clear();
          directUsers_initial.clear();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              elevation: 0, //removes shadow

              automaticallyImplyLeading:
                  false, //Remove default appbar top-left button
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                  directUsers_initial = [];
                  directUsersNames = [];
                },
              ),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              title: !_searchBoolean
                  ? Text("Users",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
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
                          })
                    ]
                  : [
                      IconButton(
                          icon: Icon(Icons.refresh_outlined),
                          onPressed: () {
                            setState(() {
                              _searchBoolean = false;
                              _searchIndexList = [];
                            });
                          })
                    ]),
          body: !_searchBoolean ? Userlist() : SearchUserlist(),
        ),
      );

  Widget _buildAvatar(types.User user) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
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

  Widget Userlist() {
    return StreamBuilder<List<types.User>>(
      stream: FirebaseChatCore.instance.users(),
      initialData: const [],
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
              bottom: 200,
            ),
            child: const Text('No users'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            searchdirect_initial.add(user);
            searchdirectusers.add(getUserName(user));

            return GestureDetector(
              onTap: () {
                _handlePressed(user, context);
              },
              child: Container(
                margin: const EdgeInsets.only(
                    top: 6, bottom: 6, right: 10, left: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(10.0), //round corners
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      //spreadRadius: 5,
                      blurRadius: 3,
                      offset: const Offset(1, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: ListTile(
                  leading: _buildAvatar(user),
                  title: Text(getUserName(user)),
                ),
              ),
            );
          },
        );
      },
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
          for (int i = 0; i < searchdirectusers.toList().length; i++) {
            if (searchdirectusers.toList()[i].contains(s.toLowerCase())) {
              _searchIndexList.add(i);
            }
          }
        });
        print('s String : $s');
        print("searchdirect_initial : $searchdirectusers");

        print("searchIndexList: $_searchIndexList");
      },
    );
  }

  Widget SearchUserlist() {
    return StreamBuilder<List<types.User>>(
      stream: FirebaseChatCore.instance.users(),
      initialData: const [],
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
              bottom: 200,
            ),
            child: const Text('No users'),
          );
        }
        if (_searchIndexList.isNotEmpty) {
          return ListView.builder(
            itemCount: _searchIndexList.length,
            itemBuilder: (context, index) {
              index = _searchIndexList[index];
              final user = snapshot.data![index];

              return GestureDetector(
                onTap: () {
                  _handlePressed(user, context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: _buildAvatar(user),
                    title: Text(getUserName(user)),
                  ),
                ),
              );
            },
          );
        } else {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
              bottom: 200,
            ),
            child: const Text('No users found'),
          );
        }
      },
    );
  }

  void _handlePressed(types.User otherUser, BuildContext context) async {
    final navigator = Navigator.of(context);
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }
}
