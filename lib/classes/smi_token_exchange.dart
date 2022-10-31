import 'dart:convert';
import 'dart:math';
import 'package:print_color/print_color.dart';
import 'package:http/http.dart' as http;
import 'package:SMI/classes/google_auth.dart';
import 'package:get/get.dart';

class SmiToken extends GetxController {
  final controller = Get.put(LoginController());
  final RxString smiAccessToken = ''.obs;
  final RxString smiRefreshToken = ''.obs;

  get() async {
    //get smi auth token (step1)

    //getRandomString function
    String getRandomString(int length) {
      const characters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
      Random random = Random();
      return String.fromCharCodes(Iterable.generate(length,
          (_) => characters.codeUnitAt(random.nextInt(characters.length))));
    }

    var state = getRandomString(15);
    var refreshToken = controller.googleAccount.value!.serverAuthCode;
    var email = controller.googleAccount.value!.email;
    var idToken = controller.googleAuth.value!.idToken;
    var accessToken = controller.googleAuth.value!.accessToken;
    var accessTokenJson = jsonEncode({
      "access_token": accessToken,
      "id_token": idToken,
      "expires_in": 3599, //seconds
      "refresh_token": refreshToken,
    });

    // Print.red("refreshToken: $refreshToken");
    // Print.red("IdToken2: $idToken");
    // Print.red("accessToken2: $accessToken");

    var url = Uri.parse('**************************');
    var response = await http.post(url, body: {
      'client_id': email,
      'access_token': accessTokenJson.toString(),
      "id_token": idToken,
      "response_type": "code",
      "state": state,
      "scope": "intranet.user.login.null",
      "provider": "google",
      "source": "mobileapp",
    });
    //Print.green('Response status: ${response.statusCode}');
    //Print.green('Response body: ${response.body}');

    var responseJson = jsonDecode(response.body);
    var authCode = responseJson['message']
        ['authcode']; //extracting authcode out of response json
    //Print.green("authCode: $authCode");

    //get smi auth token (step2)
    var url2 = Uri.parse('*****************************');
    var response2 = await http.post(url2, body: {
      'client_id': email,
      'grant_type': "authorization_code",
      "code": authCode,
    });

    //Print.green('Response body: ${response2.body}');
    var responseJson2 = jsonDecode(response2.body);
    var tempSmiAccessToken = responseJson2['message']
        ['access_token']; //extracting access_token out of response json
    var tempSmiRefreshToken = responseJson2['message']
        ['refresh_token']; //extracting refresh_token out of response json

    Print.green("smiAccessToken: $tempSmiAccessToken");
    Print.green("smiRefreshToken: $tempSmiRefreshToken");

    //setting values globally
    smiAccessToken.value = tempSmiAccessToken;
    smiRefreshToken.value = tempSmiRefreshToken;
  }

  refresh() async {
    //need to implement check at api calls if token is expired or not
    var email = controller.googleAccount.value!.email;

    var url3 = Uri.parse('******************************');
    var response3 = await http.post(url3, body: {
      'client_id': email,
      'grant_type': "refresh_token",
      "code": smiRefreshToken.value,
    });

    var responseJson3 = jsonDecode(response3.body);
    var tempSmiAccessToken = responseJson3['message']
        ['access_token']; //extracting authcode out of response json
    var tempSmiRefreshToken = responseJson3['message']
        ['refresh_token']; //extracting refresh_token out of response json

    //setting values globally
    smiAccessToken.value = tempSmiAccessToken;
    smiRefreshToken.value = tempSmiRefreshToken;
  }
}
