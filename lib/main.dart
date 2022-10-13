import 'package:SMI/views/google_login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'chat/src/get_notifications.dart';
import 'chat/src/get_notifications.dart';
import 'firebase_options.dart';

class CustomPageRoute extends MaterialPageRoute {
  //overwrites duration of material view transition to 0 so no animation is shown
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); //will lock app to portrait mode
  runApp(
    OverlaySupport(
      child: MaterialApp(
        title: 'SMI Flutter App',
        // onGenerateRoute: generateRoute,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple, // ?
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // background (button) color
              //onPrimary: Colors.black, // foreground (text) color
            ),
          ),

          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.deepPurple, //<-- SEE HERE
          ),
        ),
        home: const HomePage(),
      ),
    ),
  );
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

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    //setUpInteractedMessage();
  }
}
