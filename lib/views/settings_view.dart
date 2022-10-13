import 'package:SMI/main.dart';
import 'package:SMI/views/google_login_view.dart';
import 'package:flutter/material.dart';
import 'package:SMI/views/bluetooth_view.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../sys_proc/homepage.dart';
import '../classes/google_auth.dart';

import 'package:flutter/services.dart'; // needed for SystemUiOverlayStyle.dark

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int up = 0;
  int down = 0;
  int left = 0;
  int right = 0;
  late final TextEditingController
      _email; // late = the vales will be filled in later by the user
  late final TextEditingController
      _password; // final = const that can be changed by the user

  final Uri url_discord = Uri(
    scheme: "https",
    host: "discord.com",
  );

  final Uri url_moodle =
      Uri(scheme: "https", host: "moodle.stmartins.edu", path: "/login");

  final Uri url_intranet = Uri(
    scheme: "https",
    host: "intranet.stmartins.edu",
    path: "/login",
  );

  @override
  void initState() {
    //the following vars will be created at startup
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    //when the app will be close the following vars will be deleted
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _launchInBrowser(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    }

    final google = Get.put(LoginController());
    return AnnotatedRegion(
      //making the icons in status bar dark
      value: SystemUiOverlayStyle.dark, //making the icons in status bar dark

      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Settings Page",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  //Social media buttons
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 55, bottom: 5, left: 25, right: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.discord_outlined,
                            ),
                            label: Text("Discord"),
                            onPressed: () {
                              _launchInBrowser(url_discord);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(88, 101, 242, 100)),
                          ),
                        ),
                        SizedBox(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.book),
                            label: Text("Moodle"),
                            onPressed: () {
                              _launchInBrowser(url_moodle);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.orange),
                          ),
                        ),
                        SizedBox(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.computer),
                            label: Text("Intranet"),
                            onPressed: () {
                              _launchInBrowser(url_intranet);
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 55, bottom: 5, right: 5),
                        child: ElevatedButton.icon(
                          //minWidth: 10, //width of the button
                          label: Text("Logout"),
                          icon: Icon(Icons.logout),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                          onPressed: () async {
                            flutterBlue.stopScan();
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
                        ),
                      ),
                    ],
                  ),

                  //konami code buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: SizedBox(
                          child: IconButton(
                              color: Colors
                                  .white, //white colored so it is not visible
                              onPressed: () {
                                up++;
                                if (up > 2) {
                                  up = 0;
                                  down = 0;
                                  left = 0;
                                  right = 0;
                                }
                                konamicode(up, down, left, right);
                              },
                              icon: Icon(Icons.arrow_upward)),
                        ),
                      )
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: IconButton(
                            color: Colors
                                .white, //white colored so it is not visible
                            onPressed: () {
                              if (up == 2 && down == 2) {
                                left++;
                              } else if (down != 2 || up != 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                              }
                              if (right < 1 && left > 1) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              if (left > 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              konamicode(up, down, left, right);
                            },
                            icon: Icon(Icons.arrow_back)),
                      ),
                      SizedBox(
                        width: 100,
                        child: IconButton(
                            color: Colors
                                .white, //white colored so it is not visible
                            onPressed: () {
                              if (left <= 2) {
                                right++;
                              }
                              if (up != 2 || down != 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              if (left < 1) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              if (left == 1 && right == 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              if (right > 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              konamicode(up, down, left, right);
                              if (up == 2 &&
                                  down == 2 &&
                                  left == 2 &&
                                  right == 2) {
                                print("KONAMI");
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const EasterEgg(),
                                      transitionDuration:
                                          const Duration(seconds: 0),
                                    ));
                              }
                            },
                            icon: Icon(Icons.arrow_forward)),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: IconButton(
                            color: Colors
                                .white, //white colored so it is not visible
                            onPressed: () {
                              if (up == 2) {
                                down++;
                              } else if (up == 1 || up > 2) {
                                up = 0;
                              }
                              if (up > 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              if (down > 2) {
                                up = 0;
                                down = 0;
                                left = 0;
                                right = 0;
                              }
                              konamicode(up, down, left, right);
                            },
                            icon: Icon(Icons.arrow_downward)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  konamicode(up, down, left, right) {
    int upbutton = up;
    int downbutton = down;
    int leftbutton = left;
    int rightbutton = right;
    print("up here : $upbutton");
    print("down here : $downbutton");
    print("left here : $leftbutton");
    print("right here : $rightbutton");
    return [upbutton, downbutton, leftbutton, rightbutton];
  }
}
