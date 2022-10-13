import 'package:SMI/classes/smi_userid_and_type.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:print_color/print_color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final smiUserIdAndType = Get.put(SmiUserIdAndType());

class BluetoothScan extends GetxController {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  final RxMap<String, int> scanResults = <String, int>{}.obs;
  final RxString currentLesson = "".obs;
  final RxString currentRoom = "".obs;
  final RxString rssiLimit = "".obs;
  final RxString macAddressOfCurrentRoom = "".obs; //estimote, room 136
  final RxString distanceToCurrentRoom = "-100".obs;
  final RxString neededDistance = "".obs;
  final RxBool isCloseEnough = false.obs;
  final RxBool pushedToDatabase = false.obs;

  //simulated api output of current room macadress and rssi value:
  //  static const currentLesson = "Artifical Intelligence";
  // static const currentRoom = 136;
  // rssiPower.value = -80;

  startScan() async {
    //resetting all values
    scanResults.clear();
    currentLesson.value = "";
    currentRoom.value = "";
    macAddressOfCurrentRoom.value = "";
    distanceToCurrentRoom.value = "-100";
    neededDistance.value = "";
    isCloseEnough.value = false;
    pushedToDatabase.value = false;

    Print.green("start of startScan method");
    Print.green(smiUserIdAndType.smiUserId.value);
    //Api call to get macAddressOfCurrentRoom and rssiLimit
    try {
      var response = await http.get(Uri.parse(
          'INSERTURLHERE/getCurrentClassMacAddressAndRssi?userid=${smiUserIdAndType.smiUserId.value}&time=09:00:00&date=2020-03-05')); //time and date hardcoded right now

      Print.green('Response body: ${response.body}');
      var responseJson = jsonDecode(response.body);

      //exctracting values from api response
      var tempTtableentryid = responseJson[0]["ttableentryid"];
      var tempCurrentLesson = responseJson[0]["description"];
      var tempCurrentRoom = responseJson[0]["roomNumber"];
      var tempNeededDistance = responseJson[0]["rssiPower"].toString();
      var tempMacAddressOfCurrentRoom = responseJson[0]["macAddress"];

      // Start scanning
      await flutterBlue.startScan(timeout: const Duration(seconds: 3));

      Print.green("Bluetooth Scan started");
      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // do something with scan results

        for (ScanResult r in results) {
          Print.green("Scan result: ${r.device.name} ${r.device.id} ${r.rssi}");
          scanResults[r.device.id.toString()] = r.rssi;
          if (r.device.id.toString() == tempMacAddressOfCurrentRoom) {
            Print.red(r.advertisementData);
          }
        }
        for (ScanResult r in results) {
          // Print.red('${r.device.id} found! rssi: ${r.rssi}');
          scanResults["${r.device.id}"] =
              r.rssi; //filling map with scan results

        }
      });

      Print.red(scanResults[tempMacAddressOfCurrentRoom].toString());

      // Print.red(scanResults[macAddressOfCurrentRoom]); //accessing rssi value of Estimote beacon

      // Print.red("macAddressOfCurrentRoom" + tempMacAddressOfCurrentRoom)

      var tempDistanceToCurrentRoom = scanResults[
          tempMacAddressOfCurrentRoom]; //assigning rssi value to variable
      Print.red("tempNeededDistance: $tempNeededDistance");
      Print.red("tempDistanceToCurrentRoom: $tempDistanceToCurrentRoom");

      if (tempDistanceToCurrentRoom != null) {
        if (tempDistanceToCurrentRoom >= int.parse(tempNeededDistance)) {
          Print.green("You are in the classroom");
          isCloseEnough.value = true;
        } else {
          Print.red("You are not in the classroom");
          isCloseEnough.value = false;
        }
      } else {
        Print.red("You are not in the classroom");
        isCloseEnough.value = false;
      }

      //pushing isCloseEnough value true to api
      if (isCloseEnough == true) {
        var response2 = await http.get(Uri.parse(
            'INSERTURLHERE/saveAutoAttendance?ttableentryid=$tempTtableentryid&userid=${smiUserIdAndType.smiUserId.value}&attendanceState=1'));
        // Print.green('Response body2: ${response2.body}');
        var responseJson2 = jsonDecode(response2.body);
        var responseStatus2 = responseJson2["status"];
        Print.green("responseStatus2: $responseStatus2");

        if (responseStatus2 == "completed") {
          pushedToDatabase.value = true;
        }
      }

      //setting other global values at end because RxInt RxString is not good for calculations
      currentLesson.value = tempCurrentLesson;
      currentRoom.value = tempCurrentRoom;
      macAddressOfCurrentRoom.value = tempMacAddressOfCurrentRoom;
      distanceToCurrentRoom.value = tempDistanceToCurrentRoom.toString();
      neededDistance.value = tempNeededDistance;

      // Stop scanning
      await flutterBlue.stopScan();
      Print.green("end of startScan method");
    } catch (e) {
      Print.red("Error in api call: $e");
    }
  }
}
