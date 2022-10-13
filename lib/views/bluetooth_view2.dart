// ignore_for_file: use_build_context_synchronously

import 'package:SMI/classes/bluetooth_scan.dart';
import 'package:SMI/classes/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

class BluetoothView2 extends StatefulWidget {
  const BluetoothView2({Key? key}) : super(key: key);

  @override
  State<BluetoothView2> createState() => _BluetoothView2State();
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.black,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? "${state.toString().substring(15)} \n        Please turn on" : 'not available'}',
            ),
          ],
        ),
      ),
    );
  }
}

class MainBluetoothScreen extends StatefulWidget {
  const MainBluetoothScreen({super.key});

  @override
  State<MainBluetoothScreen> createState() => _MainBluetoothScreenState();
}

class _MainBluetoothScreenState extends State<MainBluetoothScreen> {
  final bluetooth = Get.put(BluetoothScan());
  bool showWidget = false;
  bool oncedPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        //need to set SystemUiOverlayStyle.dark,
        appBar: AppBar(
          elevation: 0, //removes shadow
          title: const Text(
            "Bluetooth Scanner",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Row contents horizontally,
            crossAxisAlignment:
                CrossAxisAlignment.center, //Center Row contents vertically,
            children: [
              FloatingActionButton.extended(
                  backgroundColor: Colors.deepPurple,
                  onPressed: () async {
                    setState(() {
                      oncedPressed = true;
                    });
                    setState(() {
                      showWidget = false;
                    });
                    await bluetooth.startScan();
                    setState(() {
                      showWidget = true;
                    });
                    if (bluetooth.isCloseEnough.value == false) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      CustomSnackbar.buildSnackbar(
                          context,
                          "Not Close Enough to Bluetooth Device",
                          Icons.error_outline,
                          Colors.red);
                    }
                    if (bluetooth.pushedToDatabase.value == true) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      CustomSnackbar.buildSnackbar(
                          context,
                          "Registered sucessfully as attendend",
                          Icons.done,
                          Colors.green);
                    }
                  },
                  label: const Text("Start scanning for Room")),
              const SizedBox(
                height: 20,
              ),
              if (showWidget == false && oncedPressed == true)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const CircularProgressIndicator(
                    color: Colors.deepPurple,
                  )
                ]),
              if (showWidget == true && oncedPressed == true)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Current Lesson: ${bluetooth.currentLesson.value}"),
                  Text("Current Room: ${bluetooth.currentRoom.value}"),
                  Text(
                      "Current Room Mac Address: ${bluetooth.macAddressOfCurrentRoom.value}"),
                  Text("Needed Distance: ${bluetooth.neededDistance.value}"),
                  Text(
                      "Your Distance to Room: ${bluetooth.distanceToCurrentRoom.value}"),
                  Text("You are in the Room: ${bluetooth.isCloseEnough.value}"),
                ]),
            ],
          ),
        ));
  }
}

class _BluetoothView2State extends State<BluetoothView2> {
  //here the view starts building

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: flutterBlue.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            // wait 1 second until the bluetooth is ready
            //sleep(const Duration(seconds: 1));

            if (state == BluetoothState.on) {
              return const MainBluetoothScreen();
            }

            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
