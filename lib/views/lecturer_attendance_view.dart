import 'package:SMI/views/lecturer_calendar_view.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../classes/custom_snackbar.dart'; //for time formatting

List<StudentsByCourses> studentsByCoursesFromJson(String str) =>
    List<StudentsByCourses>.from(
        json.decode(str).map((x) => StudentsByCourses.fromJson(x)));

String studentsByCoursesToJson(List<StudentsByCourses> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudentsByCourses {
  StudentsByCourses({
    required this.studentId,
    required this.name,
    required this.surname,
    required this.ttableentryid,
  });

  int studentId;
  String name;
  String surname;
  int ttableentryid;

  factory StudentsByCourses.fromJson(Map<String, dynamic> json) =>
      StudentsByCourses(
        studentId: json["StudentId"],
        name: json["name"],
        surname: json["surname"],
        ttableentryid: json["ttableentryid"],
      );

  Map<String, dynamic> toJson() => {
        "StudentId": studentId,
        "name": name,
        "surname": surname,
        "ttableentryid": ttableentryid,
      };
}

Future<List<StudentsByCourses>> getStudentsByCourse(int ttableentryid) async {
  final response = await http.get(Uri.parse(
      'INSERTURLHERE/getStudentsByCourse?ttableentryid=$ttableentryid'));

  if (response.statusCode == 200) {
    return studentsByCoursesFromJson(response.body);
  } else {
    throw Exception('Failed to getStudentsByCourse');
  }
}

class LecturerAttendanceView extends StatefulWidget {
  final String current_course_name;
  final String current_courseRole;
  final String current_start_date;
  final String current_end_date;
  final String current_room_number;
  final String current_description;
  final ttableentryid;
  final String current_ttabledate;

  const LecturerAttendanceView(
      {super.key,
      required this.current_course_name,
      required this.current_courseRole,
      required this.current_start_date,
      required this.current_end_date,
      required this.current_room_number,
      required this.current_description,
      required this.ttableentryid,
      required this.current_ttabledate});
  @override
  State<LecturerAttendanceView> createState() => _LecturerAttendanceView();
}

class _LecturerAttendanceView extends State<LecturerAttendanceView> {
  late List<bool> _isChecked;
  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(1000, false);

    List<StudentsByCourses> attendance_init = [];
    print(attendance_init);
  }

  SaveAttendance(int ttableentryid, String userid, int attendancestate) async {
    print("Save Attendance");
    final response = await http.get(Uri.parse(
        'https://api.stmartins.edu/rest/site/SMIApp/saveConfirmedAttendance?ttableentryid=$ttableentryid&userid=$userid&attendanceState=$attendancestate'));

    if (response.statusCode == 200) {
      print("Database Updated");
    } else {
      throw Exception('Failed to push saveConfirmedAttendance');
    }
  }

  var attendance = {};
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    DateTime newstarttime = DateTime.parse(widget.current_start_date);
    DateTime newendtime = DateTime.parse(widget.current_end_date);
    DateTime newdate = DateTime.parse(widget.current_ttabledate);
    var prettyCourseRole = "";
    if (widget.current_courseRole.contains("SMI")) {
      prettyCourseRole = "SMI";
    } else if (widget.current_courseRole.contains("UOL")) {
      prettyCourseRole = "UOL";
    } else {
      prettyCourseRole = widget.current_courseRole;
    }
    return Scaffold(
      appBar: (AppBar(
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0, //removes shadow
        title: const Text(
          "Attendance List",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.white,
      )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            margin:
                const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0), //round corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  //spreadRadius: 5,
                  blurRadius: 3,
                  offset: const Offset(1, 2), // changes position of shadow
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.current_description}\nRoom: ${widget.current_room_number}\nClass: ${widget.current_course_name} \n${DateFormat.Hm().format(newstarttime).toString()} - ${DateFormat.Hm().format(newendtime).toString()}  ${DateFormat.yMMMMEEEEd().format(newdate).toString()}\nCertificate: $prettyCourseRole',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          FutureBuilder<List<StudentsByCourses>>(
            future: getStudentsByCourse(widget.ttableentryid),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  height: screenHeight * 0.6,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      var details = {
                        '${snapshot.data![index].studentId}':
                            '${_isChecked[index]}'
                      };
                      attendance.addAll(details);
                      return Container(
                        margin: const EdgeInsets.only(
                            top: 6, bottom: 6, right: 10, left: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(10.0), //round corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              //spreadRadius: 5,
                              blurRadius: 3,
                              offset: const Offset(
                                  1, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                              "Privacy Placeholder Student Name"),  //'${snapshot.data![index].name} ${snapshot.data![index].surname}'),
                          trailing: Checkbox(
                            value: _isChecked[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked[index] = value!;
                                print(_isChecked[index]);
                                var details = {
                                  '${snapshot.data![index].studentId}':
                                      '${_isChecked[index]}'
                                };
                                attendance.addAll(details);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                printError(info: snapshot.error.toString());
              } else {
                return const Center(child: CircularProgressIndicator());
              }
              throw UnimplementedError();
            },
          ),
          SizedBox(
            width: screenWidth * 0.5,
            height: screenHeight * 0.08,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                CustomSnackbar.buildSnackbar(
                    context,
                    "The student attendance has been saved",
                    Icons.done,
                    Colors.green);

                for (var key in attendance.keys) {
                  // print(key); //StudentID
                  // print(attendance[key]);

                  var userid = key;
                  int attendancestate = 0;
                  var ttableentryid = widget.ttableentryid;

                  if (attendance[key] == 'true') {
                    SaveAttendance(widget.ttableentryid, userid, 1);
                  } else {
                    SaveAttendance(widget.ttableentryid, userid, 0);
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
