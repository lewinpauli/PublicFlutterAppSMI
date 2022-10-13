import 'dart:convert';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; //for time formatting
//Datetime in Flutter cheatsheet https://www.flutterbeads.com/format-datetime-in-flutter/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // needed for SystemUiOverlayStyle.dark
import 'package:print_color/print_color.dart';
import 'package:table_calendar/table_calendar.dart';
import '../classes/google_auth.dart';
import '../classes/smi_userid_and_type.dart';

final smiUserIdAndType = Get.put(SmiUserIdAndType());
//import 'package:google_sign_in/google_sign_in.dart';

//check out readme of table calendar: https://github.com/aleksanderwozniak/table_calendar
//and examples: https://github.com/aleksanderwozniak/table_calendar/tree/master/example/lib/pages

//Start StudentDaySchedule

//with this you can create the class easy from json https://app.quicktype.io/

List<StudentDaySchedule> studentDayScheduleFromJson(String str) =>
    List<StudentDaySchedule>.from(
        json.decode(str).map((x) => StudentDaySchedule.fromJson(x)));

String studentDayScheduleToJson(List<StudentDaySchedule> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudentDaySchedule {
  StudentDaySchedule({
    required this.studentId,
    required this.start,
    required this.end,
    required this.description,
    required this.ttabledate,
    required this.roomNumber,
    required this.lecturerName,
    required this.lecturerSurname,
    required this.confirmedAttendance,
  });

  int studentId;
  DateTime start;
  DateTime end;
  DateTime ttabledate;
  String description;
  String roomNumber;
  String lecturerName;
  String lecturerSurname;
  int confirmedAttendance;

  factory StudentDaySchedule.fromJson(Map<String, dynamic> json) =>
      StudentDaySchedule(
        studentId: json["StudentId"],
        start: DateTime.parse(
            json["start"]), //DateTime.parse converts Datetime to string
        end: DateTime.parse(json["end"]),
        ttabledate: DateTime.parse(json["ttabledate"]),
        description: json["description"],
        roomNumber: json["roomNumber"],
        lecturerName: json["lecturerName"],
        lecturerSurname: json["lecturerSurname"],
        confirmedAttendance: json["confirmedAttendance"],
      );

  Map<String, dynamic> toJson() => {
        "StudentId": studentId,
        "start": start.toString(),
        "end": end.toString(),
        "ttabledate": ttabledate.toString(),
        "description": description,
        "roomNumber": roomNumber,
        "lecturerName": lecturerName,
        "lecturerSurname": lecturerSurname,
        "confirmedAttendance": confirmedAttendance,
      };
}

Future<List<StudentDaySchedule>> getStudentDayScheduleList(
    DateTime date) async {
  final response = await http.get(Uri.parse(
      'INSERTURLHERE/getStudentDaySchedule?userid=${smiUserIdAndType.smiUserId.value}&date=$date')); //2020-03-05

  if (response.statusCode == 200) {
    return studentDayScheduleFromJson(response.body);
  } else {
    throw Exception('Failed to load StudentDaySchedule');
  }
} //End StudentDaySchedule

class StudentCalendarView extends StatefulWidget {
  const StudentCalendarView({Key? key}) : super(key: key);

  @override
  State<StudentCalendarView> createState() => _StudentCalendarViewState();
}

class _StudentCalendarViewState extends State<StudentCalendarView> {
  CalendarFormat _calendarFormat =
      CalendarFormat.week; // starting with Calendarformat.month
  DateTime _focusedDay =
      DateTime(2020, 3, 5); //DateTime.now(); //hardcoded start date for testing
  DateTime? _selectedDay;
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    // Print.red(controller.googleAccount.value?.serverAuthCode ??
    //     'serverAuthCode not loaded');
    // controller.accessToken();

    if (_selectedDay == null) {
      //at start, if no date is selected, select today
      _selectedDay = _focusedDay;
    }
    return AnnotatedRegion(
      //making the icons in status bar dark
      value: SystemUiOverlayStyle.dark, //making the icons in status bar dark

      child: Scaffold(
        appBar: AppBar(
          elevation: 0, //removes shadow
          automaticallyImplyLeading:
              false, //removes left back button from AppBar
          title: const Text(
            "Calendar",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // //Headline
                // const Text(
                //   "Calendar Page",
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 18,
                //   ),
                // ),

                //Text("welcome " + FirebaseAuth.instance.currentUser!.displayName!),
                //FirebaseAuth.instance.currentUser!.getIdTokenResult().then((value) => print(value.claims)).toString(),
                // Text("google id token: " +  GoogleAuthCredentia   toString()),
                Text(controller.googleAccount.value?.displayName ??
                    "name not loaded"),
                Text(controller.googleAccount.value?.email ??
                    "email not loaded"),

                //Calendar Widget
                Container(
                  margin: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 10, left: 10),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TableCalendar(
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                            color: Colors.deepPurple, shape: BoxShape.circle),
                      ),
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2010, 1, 1),
                      lastDay: DateTime.utc(2200, 1, 1),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        //when clicking on format button, the format will loop between month, 2week and week
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      selectedDayPredicate: (day) {
                        // Use `selectedDayPredicate` to determine which day is currently selected.
                        // If this returns true, then `day` will be marked as selected.

                        // Using `isSameDay` is recommended to disregard
                        // the time-part of compared DateTime objects.

                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        //when clicking on a day, the day will be selected
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          // Call `setState()` when updating the selected day
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        //should be called when page is changed and set selected Day to focused Day
                        // No need to call `setState()` here
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                ),

                // Text(_selectedDay.toString()),

                Center(
                  //dynamic StudentDaySchedule List
                  child: FutureBuilder<List<StudentDaySchedule>>(
                    future: getStudentDayScheduleList(DateFormat("yyyy-MM-dd")
                        .parse(_selectedDay
                            .toString())), //only taking date out of _selectedDay //example value: 2020-03-05
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<StudentDaySchedule>? data = snapshot.data;
                        return SizedBox(
                          height: 400, //needed to make its scrollable
                          child: ListView.builder(
                            // shrinkWrap: true, // to make listview inside column
                            // scrollDirection: Axis.vertical,
                            // physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              String prettyAttendance = "";
                              if (data[index].confirmedAttendance == 1) {
                                prettyAttendance = "Yes";
                              } else {
                                prettyAttendance = "No";
                              }
                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 6, bottom: 6, right: 10, left: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      10.0), //round corners
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
                                  isThreeLine: true,
                                  title: Text(data[index].description),
                                  subtitle: Text(DateFormat.Hm()
                                              .format(data[index].start)
                                              .toString() +
                                          " - " +
                                          DateFormat.Hm()
                                              .format(data[index].end)
                                              .toString() +
                                          "  " +
                                          DateFormat.yMMMMEEEEd()
                                              .format(data[index].ttabledate)
                                              .toString() +
                                          "\nLecturer: " +
                                          data[index].lecturerName +
                                          " " +
                                          data[index].lecturerSurname +
                                          "\nRoom: " +
                                          data[index].roomNumber +
                                          "\nConfirmed Attendance: " +
                                          prettyAttendance //== "1" ? "Yes" : "No"

                                      ), //only display hour and minute from "start" and "end", and only display date of "ttabledate" //example original value for tabledate: 2020-03-05 00:00:00
                                ),
                              );
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
