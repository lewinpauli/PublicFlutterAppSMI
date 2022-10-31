// ignore_for_file: use_build_context_synchronously

import 'package:SMI/classes/google_auth.dart';
import 'package:SMI/classes/smi_token_exchange.dart';
import 'package:SMI/classes/smi_userid_and_type.dart';
import 'package:SMI/config.dart';
import 'package:SMI/views/admin_view.dart';
import 'package:SMI/views/lecturer_redirect_view.dart';
import 'package:SMI/views/student_redirect_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_color/print_color.dart';

import '../classes/custom_snackbar.dart';

class GoogleLoginView extends StatelessWidget {
  GoogleLoginView({Key? key}) : super(key: key);
  final google = Get.put(LoginController());
  // final smiToken = Get.put(SmiToken());
  final smiUserIdAndType = Get.put(SmiUserIdAndType());

  @override
  Widget build(BuildContext context) {
    // if (controller.googleAccount.value != null) {
    // Navigator.push(
    //                   context,
    //                   PageRouteBuilder(
    //                     pageBuilder: (_, __, ___) => const RedirectView(),
    //                     transitionDuration: const Duration(seconds: 0),
    //                   ));
    // }
    // else {
    return WillPopScope(
        onWillPop: () async => false, //removes the option to swipe back
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, //Center Row contents vertically,
                    children: [
                      Image.asset("images/smi2.png", width: 50),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text(
                        "Welcome to\nSaint Martin's Institute\nof Higher Education",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // const Text("Please login with your\nSMI Google Account:",
                //     style: TextStyle(fontSize: 30)),
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton.extended(
                  onPressed: () async {
                    //GoogleSignIn().signIn();
                    try {
                      await google.login();
                      //get smi auth token

                      //await controller.accessToken(); // prints

                    } catch (e) {
                      if (e.toString().contains("network")) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        CustomSnackbar.buildSnackbar(
                            context,
                            "No Network Connection",
                            Icons.wifi_off,
                            Colors.red);
                      } else {
                        Print.red(e);
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        CustomSnackbar.buildSnackbar(context, e.toString(),
                            Icons.error_outline, Colors.red);
                      }
                    }

                    //Print.red(controller.googleAccount.value?.email);

                    // ignore: unnecessary_string_escapes
                    RegExp exp = RegExp(
                        "(?<=\@).*"); //this will cut out everything after the @

                    if (google.googleAccount.value?.email != null) {
                      String googleusermail =
                          google.googleAccount.value?.email ?? "";
                      RegExpMatch? regexdomain = exp.firstMatch(googleusermail);
                      // Print.red(regexdomain?[0]); // "Parse"

                      if (regexdomain?[0] == "someregexp") {
                        //get smi token
                        // await smiToken.get(); //deactivated because iOS cannot get serverAuthCode

                        // Print.red("SmiAccessToken2: " +
                        //     smiToken.smiAccessToken.value);
                        //Print.red("Refreshtoken2: " + smiToken.smiRefreshToken.value);
                        await smiUserIdAndType.get();
                        Print.red(
                            "SmiUserId: " + smiUserIdAndType.smiUserId.value);
                        Print.red("SmiUserType: " +
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
                        } else if (smiUserIdAndType.smiUserType.value == "A") {
                          //when user is an admin
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const AdminView(), //should be changed to admin page where admin can choose between student and lecturer, and can change bluetooth macadresses
                                transitionDuration: const Duration(seconds: 0),
                              ));
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          CustomSnackbar.buildSnackbar(
                              context,
                              "Logged in successfully as Admin",
                              Icons.done,
                              Colors.green);
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          CustomSnackbar.buildSnackbar(
                              context,
                              "Error when getting SMI Usertype",
                              Icons.error_outline,
                              Colors.red);
                          await google.logout();
                        }

                        // Navigator.push(
                        //     context,DARK
                        //     PageRouteBuilder(
                        //       pageBuilder: (_, __, ___) => const StudentRedirectView(),
                        //       transitionDuration: const Duration(seconds: 0),
                        //     ));

                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        CustomSnackbar.buildSnackbar(
                            context,
                            "Please login with your SMI Account",
                            Icons.supervised_user_circle,
                            Colors.red);
                        await google.logout();
                      }
                    }

                    // Navigator.push(
                    //     context,
                    //     PageRouteBuilder(
                    //       pageBuilder: (_, __, ___) => const RedirectView(),
                    //       transitionDuration: const Duration(seconds: 0),
                    //     ));
                    // ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    // CustomSnackbar.buildSnackbar(context,
                    //     "Logged in successfully", Icons.done, Colors.green);
                  },
                  icon: Image.asset(
                    'images/google2.png',
                    height: 32,
                  ),
                  label: const Text("Login with Google"),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),

                const SizedBox(
                  height: 300,
                ),
                FloatingActionButton.extended(
                    onPressed: () {
                      currentTheme.switchTheme();
                    },
                    label: const Text('switch theme'),
                    icon: const Icon(Icons.brightness_high)),
              ],
            ),
          ),
        ));
  }
}
