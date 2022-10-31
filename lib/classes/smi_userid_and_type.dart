import 'dart:convert';
import 'package:SMI/classes/smi_token_exchange.dart';
import 'package:print_color/print_color.dart';
import 'package:http/http.dart' as http;
import 'package:SMI/classes/google_auth.dart';
import 'package:get/get.dart';

class SmiUserIdAndType extends GetxController {
  final google = Get.put(LoginController());
  final smiToken = Get.put(SmiToken());

  final RxString smiUserId = ''.obs;
  final RxString smiUserType = ''.obs;

  get() async {
    var email = google.googleAccount.value!.email;

    var accesstoken = smiToken.smiAccessToken.value;

    var url = Uri.parse('https://apiprovider/getUserType?email=$email');
    var response = await http.get(url);
    //Print.green('Response status: ${response.statusCode}');
    Print.green('Response body: ${response.body}');

    if (response.statusCode == 254) {
      //254 is the status code for invalid access token
      //get new token
      smiToken.refresh();
      //call this function again
      get();
    } else if (response.statusCode == 200) {
      //when the api call worked
      var responseJson = jsonDecode(response.body);
      var userId = responseJson[0]['userid'].toString();
      var userType = responseJson[0]['Type'];
      smiUserId.value = userId;
      smiUserType.value = userType;
      Print.green("SMIuserId: $userId");
      Print.green("SMIuserType: $userType");
    } else {
      Print.red("Error: ${response.body}");
    }
  }
}
