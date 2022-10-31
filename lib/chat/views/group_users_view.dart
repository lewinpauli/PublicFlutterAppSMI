import 'package:SMI/classes/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart'; //for time formatting

import 'direct_chat_view.dart';
import 'chat_views_util.dart';

//Add User to Group View

late List<String> groupUsersNames = [];
late List<String> groupUsersIds = [];
late List<types.User> groupUsers_initial = [];

var name = "";
late List<bool> _isChecked;

class GroupUsersPage extends StatefulWidget {
  _GroupUsersPageState createState() => _GroupUsersPageState();
  const GroupUsersPage({super.key});
}

class _GroupUsersPageState extends State<GroupUsersPage> {
  //Initialize search variables
  bool _searchBoolean = false; //add search view switch boolean operator
  List<int> _searchIndexList = []; //add
  List searchgroup_initial = []; // add search list user arrays
  Set searchgroupusers = {}; //add search list usernames

  var _isChecked =
      List<bool>.filled(1000, false); // INIT Booelan list for checkbox values

  //AlertDialog for creating a new group
  showAlertDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    name = "";
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(20.0))), //round corners
      elevation: 0,
      // insetPadding: EdgeInsets.all(10),
      title: Text("Group Creation"),
      titlePadding: EdgeInsets.all(20),
      content: TextField(
        onChanged: (value) {
          name = value;
        },
        decoration: InputDecoration(hintText: "Enter Group Name"),
        textAlign: (TextAlign.center),
      ),
      actions: [
        SingleChildScrollView(
          child: Container(
            margin:
                const EdgeInsets.only(top: 6, bottom: 6, right: 10, left: 10),
            height: screenHeight * 0.3,
            width: screenWidth * 0.8,
            child: ListView.builder(
              itemCount: groupUsersNames.length,
              itemBuilder: (context, index) {
                if (groupUsersNames.isNotEmpty) {
                  return ListTile(
                    leading: _buildAvatar(groupUsers_initial[index]),
                    title: Text(groupUsersNames[index]),
                  );
                } else {
                  return const Text("No users");
                }
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                  //groupUsersNames.clear();
                  // Delete value of groupUsers_initial on Cancelling
                },
                child: Text("Cancel")),
            ElevatedButton(
              child: Text("Create Group"),
              onPressed: () {
                if (name == "") {
                  Navigator.of(context).pop();
                  CustomSnackbar.buildSnackbar(context,
                      "Please enter a group name", Icons.warning, Colors.red);
                } else if (groupUsers_initial.isEmpty) {
                  Navigator.of(context).pop();
                  CustomSnackbar.buildSnackbar(
                      context,
                      "Please select atleast one user",
                      Icons.warning,
                      Colors.red);
                } else {
                  Navigator.of(context).pop();
                  CreateGroup(groupUsers_initial, name, context);
                }
              },
            ),
          ],
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          groupUsersNames.clear();
          groupUsersIds.clear();
          groupUsers_initial.clear();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              elevation: 0, //removes shadow

              backgroundColor: Theme.of(context).backgroundColor,
              automaticallyImplyLeading:
                  false, //Remove default appbar top-left button
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                  groupUsers_initial = [];
                  groupUsersNames = [];
                },
              ),
              systemOverlayStyle: SystemUiOverlayStyle.light,
              title: !_searchBoolean
                  ? const Text("Add Users to Group",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ))
                  : _searchTextField(),
              actions: !_searchBoolean
                  ? [
                      IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              _searchBoolean = true;
                              _searchIndexList = [];
                            });
                          })
                    ]
                  : [
                      IconButton(
                          icon: const Icon(Icons.refresh_outlined),
                          onPressed: () {
                            setState(() {
                              _searchBoolean = false;
                              _searchIndexList = [];
                            });
                          })
                    ]),
          body: !_searchBoolean ? Userlist() : SearchUserlist(),
          floatingActionButton: Container(
            child: FloatingActionButton(
              onPressed: () {
                showAlertDialog(context);
                // _handlePressed(groupUsers_initial, name, context);
              },
              child: const Icon(Icons.add),
            ),
          ),
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
            searchgroup_initial.add(user);
            searchgroupusers.add(getUserName(user));

            return GestureDetector(
              onTap: () {
                //_handlePressed(groupUsers, name, context);
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
                  trailing: Checkbox(
                    value: _isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked[index] = value!;
                      });
                      if (_isChecked[index] == true) {
                        groupUsers_initial.add(user);
                        groupUsersNames.add(getUserName(user));
                        groupUsersIds.add(user.id);
                        print("Searchgroup : $searchgroup_initial");
                      } else {
                        //searchgroupusers.remove(getUserName(user));
                        groupUsers_initial.remove(user);
                        groupUsersNames.remove(getUserName(user));
                        groupUsersIds.remove(user.id);
                      }
                    },
                  ),
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
          for (int i = 0; i < searchgroupusers.toList().length; i++) {
            if (searchgroupusers.toList()[i].contains(s)) {
              _searchIndexList.add(i);
            }
          }
        });
        print('s String : $s');
        print("searchgroup_initial : $searchgroupusers");

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
                  //_handlePressed(groupUsers, name, context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: _buildAvatar(user),
                    title: Text(getUserName(user)),
                    trailing: Checkbox(
                      value: _isChecked[index],
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked[index] = value!;
                        });
                        if (_isChecked[index] == true) {
                          groupUsers_initial.add(user);
                          groupUsersNames.add(getUserName(user));
                          groupUsersIds.add(user.id);
                          //searchgroupusers.remove(getUserName(user));
                        } else {
                          groupUsers_initial.remove(user);
                          groupUsersNames.remove(getUserName(user));
                          groupUsersIds.remove(user.id);
                        }
                      },
                    ),
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

  void CreateGroup(
      List<types.User> groupUsers, String name, BuildContext context) async {
    final navigator = Navigator.of(context);
    final room = await FirebaseChatCore.instance.createGroupRoom(
      name: name,
      users: groupUsers,
    );

    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
    var _isChecked = List<bool>.filled(1000, false);
  }
}
