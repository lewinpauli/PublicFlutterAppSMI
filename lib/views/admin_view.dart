import 'dart:ui';

import 'package:SMI/chat/views/chat_views_util.dart';
import 'package:SMI/views/google_login_view.dart';
import 'package:SMI/views/lecturer_redirect_view.dart';
import 'package:SMI/views/student_redirect_view.dart';
import 'package:flutter/material.dart';
import 'package:SMI/views/bluetooth_view.dart';
import 'package:get/get.dart';
import 'package:print_color/print_color.dart';

import '../classes/custom_snackbar.dart';
import '../classes/google_auth.dart';

import 'package:flutter/services.dart';

import '../classes/smi_userid_and_type.dart'; // needed for SystemUiOverlayStyle.dark

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final smiUserIdAndType = Get.put(SmiUserIdAndType());
  final google = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final google = Get.put(LoginController());
    // final bluetooth = Get.put(BluetoothScan());

    const List<String> dowpdownList = <String>[
      'select',
      'L',
      'S',
    ];
    String dropdownValue = dowpdownList.first;

    return AnnotatedRegion(
      //making the icons in status bar dark
      value: SystemUiOverlayStyle.dark, //making the icons in status bar dark

      child: Scaffold(
        //need to set SystemUiOverlayStyle.dark,
        appBar: AppBar(
          automaticallyImplyLeading:
              false, //removes left back button from AppBar
          elevation: 0, //removes shadow
          title: const Text(
            "Admin View",
            // style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //logout button
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, //Center Row contents vertically,
                    children: [
                      const Text(
                        "Logout:  ",
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                        child: FloatingActionButton.extended(
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(
                          //         18)), //rounds the button
                          onPressed: () async {
                            // flutterBlue.stopScan();
                            await google.logout();
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      GoogleLoginView(),
                                  transitionDuration:
                                      const Duration(seconds: 0),
                                ));
                          },
                          label: Icon(Icons.logout),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Current Email: " + google.googleAccount.value!.email),

                  const SizedBox(
                    height: 20,
                  ),

                  Text("Current SMI UserId: " +
                      smiUserIdAndType.smiUserId.value),

                  const SizedBox(
                    height: 20,
                  ),

                  Text("Current SMI Usertype: " +
                      smiUserIdAndType.smiUserType.value),

                  const SizedBox(
                    height: 20,
                  ),

                  //Dropdown menu to set smiUserIdAndType.smiUserId.value
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, //Center Row contents vertically,
                    children: [
                      const Text(
                        "Change Usertype:  ",
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      DropdownButton<String>(
                        value: dropdownValue,
                        dropdownColor: Theme.of(context).backgroundColor,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        underline: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor),
                          height: 2,
                        ),
                        onChanged: (String? dropdownValue) {
                          // This is called when the user selects an item.
                          setState(() {
                            smiUserIdAndType.smiUserType.value = dropdownValue!;
                            dropdownValue = dropdownValue;
                          });
                        },
                        items: dowpdownList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  Container(
                    margin: const EdgeInsets.all(20),
                    child: TextField(
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          smiUserIdAndType.smiUserId.value = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Change User ID",
                        hintText:
                            "recommended 3727 for student or 1878 for lecturer",
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(20.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text('Submit'),
                      onPressed: () async {
                        // await  bluetooth.startScan();
                        // Print.green(bluetooth.scanResults.value);

                        Print.green(
                            "SMI User ID: " + smiUserIdAndType.smiUserId.value);
                        Print.green("SMI User Type: " +
                            smiUserIdAndType.smiUserType.value);

                        if (smiUserIdAndType.smiUserType.value == "S") {
                          //when user is a student
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const StudentRedirectView(),
                                transitionDuration: const Duration(seconds: 0),
                              ));
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          CustomSnackbar.buildSnackbar(
                              context,
                              "Logged in successfully as Student",
                              Icons.done,
                              Colors.green);
                        } else if (smiUserIdAndType.smiUserType.value == "L") {
                          //when user is a student
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const LecturerRedirectView(),
                                transitionDuration: const Duration(seconds: 0),
                              ));
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          CustomSnackbar.buildSnackbar(
                              context,
                              "Logged in successfully as Lecturer",
                              Icons.done,
                              Colors.green);
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
