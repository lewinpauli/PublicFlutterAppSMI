import 'package:SMI/views/firebase_login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //needed for SystemUiOverlayStyle.dark
import 'package:SMI/classes/custom_snackbar.dart'; //my CustomSnackbar class

//this file will not be used in final app... googlelogin will be used...

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController
      _email; // late = the vales will be filled in later by the user
  late final TextEditingController
      _password; // final = const that can be changed by the user

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
                  Text(
                    "Welcome to Saint Martins App!",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  //Email Field
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20, right: 25, left: 25, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          cursorColor: Colors.deepPurple,
                          controller: _email,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Email"),
                        ),
                      ),
                    ),
                  ),

                  //Password Field
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 25, left: 25, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          cursorColor: Colors.deepPurple,
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Password"),
                        ),
                      ),
                    ),
                  ),

                  //Registration Button
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 99999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        //child: Padding(
                        child: TextButton(
                            onPressed: () async {
                              // async because it needs to wait for authentication
                              final email = _email
                                  .text; //final = const that can be changed by user
                              final password = _password.text;

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar(); // to avoid snackbar queueing
                                CustomSnackbar.buildSnackbar(
                                    context,
                                    "Email or Password is empty",
                                    Icons.error_outline,
                                    Colors.red);
                                return;
                              }

                              try {
                                final userCredential = await FirebaseAuth
                                    .instance
                                    .createUserWithEmailAndPassword(
                                        email: email, //
                                        password: password);
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar(); // to avoid snackbar queueing
                                CustomSnackbar.buildSnackbar(
                                    context,
                                    "Registrated successfully as:\n$email",
                                    Icons.done,
                                    Colors.green);
                              } on FirebaseException catch (e) {
                                if (e.code == "weak-password") {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(); // to avoid snackbar queueing
                                  CustomSnackbar.buildSnackbar(
                                      context,
                                      "Weak password",
                                      Icons
                                          .no_encryption_gmailerrorred_outlined,
                                      Colors.red);
                                } else if (e.code == "invalid-email") {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(); // to avoid snackbar queueing
                                  CustomSnackbar.buildSnackbar(
                                      context,
                                      "Invalid email, please try again",
                                      Icons.error_outline,
                                      Colors.red);
                                } else if (e.code == "email-already-in-use") {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(); // to avoid snackbar queueing
                                  CustomSnackbar.buildSnackbar(
                                      context,
                                      "Email is already in use",
                                      Icons.error_outline,
                                      Colors.red);
                                } else if (e.code == "network-request-failed") {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(); // to avoid snackbar queueing
                                  CustomSnackbar.buildSnackbar(
                                      context,
                                      "No Internet Connection",
                                      Icons.wifi_off_sharp,
                                      Colors.red);
                                } else if (e.code == "too-many-requests") {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(); // to avoid snackbar queueing
                                  CustomSnackbar.buildSnackbar(
                                      context,
                                      "Slow down my friend 😉",
                                      Icons.access_time_sharp,
                                      Colors.red);
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(); // to avoid snackbar queueing
                                  CustomSnackbar.buildSnackbar(context, e.code,
                                      Icons.error_outline, Colors.red);
                                }
                              }
                            },
                            child: const Text("Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ),
                      //),
                    ),
                  ),

                  // Login here Button
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .removeCurrentSnackBar(); //removing current popup
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginView(),
                            transitionDuration: const Duration(seconds: 0),
                          ),
                        );
                      },
                      child:
                          const Text("You already have an account?\nLogin here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
