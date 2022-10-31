import 'package:SMI/config.dart';
import 'package:SMI/views/google_login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'chat/src/get_notifications.dart';
import 'classes/theme.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class CustomPageRoute extends MaterialPageRoute {
  //overwrites duration of material view transition to 0 so no animation is shown
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      print('changes');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMI Flutter App',
      // onGenerateRoute: generateRoute,
      navigatorKey: navigatorKey,
      theme: AppTheme().lightTheme,
      darkTheme: AppTheme().darkTheme,
      themeMode: currentTheme.currentTeme(),
      home: const HomePage(),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        //making the icons in status bar dark
        value: SystemUiOverlayStyle.dark, //making the icons in status bar dark

        child: FutureBuilder(
          future: Firebase.initializeApp(
            //initializing firebase only once for performance
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState
                  .done: //when firebase has connection etablished start building the app
                return GoogleLoginView();
              default:
                return const Scaffold(
                  //will be displayed when firebase is not connected
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
            }
          },
        ));
  }
}
