import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

//right now no value from api is allowed to be null

List<LocationData> locationDataFromJson(String str) => List<LocationData>.from(
    json.decode(str).map((x) => LocationData.fromJson(x)));

String locationDataToJson(List<LocationData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LocationData {
  LocationData({
    required this.locationid,
    required this.directions,
    required this.location,
    required this.macAddress,
    required this.rssiPower,
  });

  int locationid;
  String location;
  String directions;
  String macAddress;
  int rssiPower;

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        locationid: json["locationid"],
        location: json["location"],
        directions: json["directions"],
        macAddress: json["macAddress"],
        rssiPower: json["rssiPower"],
      );

  Map<String, dynamic> toJson() => {
        "locationid": locationid,
        "location": location,
        "directions": directions,
        "macAddress": macAddress,
        "rssiPower": rssiPower,
      };
}

Future<List<LocationData>> getLocationData() async {
  final response = await http.get(
      Uri.parse("INSERTURLHERE/getLocations"));

  if (response.statusCode == 200) {
    return locationDataFromJson(response.body);
  } else {
    throw Exception('Failed to load Room/Bluetooth Values');
  }
}

class SQLRoomView extends StatefulWidget {
  const SQLRoomView({Key? key}) : super(key: key);

  @override
  _SQLRoomViewState createState() => _SQLRoomViewState();
}

class _SQLRoomViewState extends State<SQLRoomView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //need to set SystemUiOverlayStyle.dark,
      appBar: AppBar(
        automaticallyImplyLeading:
              false, //removes left back button from AppBar
        elevation: 0, //removes shadow
        title: const Text(
          "SQL Room/Bluetooth Mapping",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: FutureBuilder<List<LocationData>>(
          future: getLocationData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<LocationData>? data = snapshot.data;
              return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(
                        top: 6, bottom: 6, right: 10, left: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0), //round corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          //spreadRadius: 5,
                          blurRadius: 3,
                          offset:
                              const Offset(1, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text("Room: " + data[index].location),
                      subtitle: Text("Rssi: " +
                          data[index].rssiPower.toString() +
                          " \nMac Address: " +
                          data[index].macAddress),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
