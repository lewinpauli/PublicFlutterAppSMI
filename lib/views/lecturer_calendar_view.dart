import 'dart:convert';
import 'package:SMI/views/lecturer_attendance_view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; //for time formatting
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // needed for SystemUiOverlayStyle.dark
import 'package:print_color/print_color.dart';
import 'package:table_calendar/table_calendar.dart';
import '../classes/google_auth.dart';
import '../classes/smi_userid_and_type.dart';

final smiUserIdAndType = Get.put(SmiUserIdAndType());

List<DailyLecturerCourses> studentDayScheduleFromJson(String str) =>
    List<DailyLecturerCourses>.from(
        json.decode(str).map((x) => DailyLecturerCourses.fromJson(x)));

String dailyLecturerCoursesToJson(List<DailyLecturerCourses> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DailyLecturerCourses {
  DailyLecturerCourses({
    required this.roomNumber,
    required this.start,
    required this.end,
    required this.description,
    required this.ttabledate,
    required this.ttableentryid,
    required this.name,
    required this.courseRole,
  });

  String roomNumber;
  DateTime start;
  DateTime end;
  DateTime ttabledate;
  String description;
  int ttableentryid;
  String name;
  String courseRole;

  factory DailyLecturerCourses.fromJson(Map<String, dynamic> json) =>
      DailyLecturerCourses(
        roomNumber: json["roomNumber"],
        start: DateTime.parse(
            json["start"]), //DateTime.parse converts Datetime to string
        end: DateTime.parse(json["end"]),
        ttabledate: DateTime.parse(json["ttabledate"]),
        description: json["description"],
        ttableentryid: json["ttableentryid"],
        name: json["name"],
        courseRole: json["courseRole"],
      );

  Map<String, dynamic> toJson() => {
        "roomNumber": roomNumber,
        "start": start.toString(),
        "end": end.toString(),
        "ttabledate": ttabledate.toString(),
        "description": description,
        "ttableentryid": ttableentryid,
        "name": name,
        "courseRole": courseRole,
      };
}

Future<List<DailyLecturerCourses>> getStudentDayScheduleList(
    DateTime date) async {
  final response = await http.get(Uri.parse(
      'https://apiprovider/getLecturerDayCourses?userid=${smiUserIdAndType.smiUserId.value}&date=$date')); //userid hardcoded right now, 2020-03-05

  if (response.statusCode == 200) {
    return studentDayScheduleFromJson(response.body);
  } else {
    throw Exception('Failed to load StudentDaySchedule');
  }
} //End StudentDaySchedule

class LecturerCalendarView extends StatefulWidget {
  const LecturerCalendarView({Key? key}) : super(key: key);

  @override
  State<LecturerCalendarView> createState() => _LecturerCalendarViewState();
}

class _LecturerCalendarViewState extends State<LecturerCalendarView> {
  CalendarFormat _calendarFormat =
      CalendarFormat.week; // starting with Calendarformat.month
  DateTime _focusedDay =
      DateTime(2020, 3, 5); //DateTime.now(); //hardcoded start date for testing
  DateTime? _selectedDay;
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(controller.googleAccount.value?.displayName ??
                    "name not loaded"),
                Text(controller.googleAccount.value?.email ??
                    "email not loaded"),

                //Calendar Widget
                Container(
                  margin: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 10, left: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(10.0), //round corners
                    boxShadow: [
                      BoxShadow(
                        //spreadRadius: 5,
                        color: Theme.of(context).shadowColor,
                        blurRadius: 3,
                        offset:
                            const Offset(1, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TableCalendar(
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
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
                  child: FutureBuilder<List<DailyLecturerCourses>>(
                    future: getStudentDayScheduleList(DateFormat("yyyy-MM-dd")
                        .parse(_selectedDay
                            .toString())), //only taking date out of _selectedDay //example value: 2020-03-05
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DailyLecturerCourses>? data = snapshot.data;
                        return SizedBox(
                          height: 400, //needed to make its scrollable
                          child: ListView.builder(
                            // shrinkWrap: true, // to make listview inside column
                            // scrollDirection: Axis.vertical,
                            // physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              var currentCourseRole = data[index].courseRole;
                              if (currentCourseRole.contains("SMI")) {
                                currentCourseRole = "SMI";
                              } else if (currentCourseRole.contains("UOL")) {
                                currentCourseRole = "UOL";
                              } else {
                                currentCourseRole = currentCourseRole;
                              }
                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 6, bottom: 6, right: 10, left: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.circular(
                                      10.0), //round corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      //spreadRadius: 5,
                                      blurRadius: 3,
                                      offset: const Offset(
                                          1, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                    isThreeLine: true,
                                    title: Text(data[index]
                                        .description), //Text(data[index].description),
                                    subtitle: Text("Room: " +
                                        data[index].roomNumber.toString() +
                                        "\n" +
                                        "Class: " +
                                        data[index].name +
                                        "\n" +
                                        DateFormat.Hm()
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
                                        " \nCertificate: " +
                                        currentCourseRole), //only display hour and minute from "start" and "end", and only display date of "ttabledate" //example original value for tabledate: 2020-03-05 00:00:00
                                    onTap: () {
                                      var current_course_name =
                                          data[index].name;
                                      var current_courseRole =
                                          data[index].courseRole;
                                      var current_start_date =
                                          data[index].start.toString();
                                      var current_end_date =
                                          data[index].end.toString();
                                      var current_room_number =
                                          data[index].roomNumber.toString();
                                      var current_description =
                                          data[index].description;
                                      var ttableentryid =
                                          data[index].ttableentryid;
                                      var current_ttabledate =
                                          data[index].ttabledate.toString();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LecturerAttendanceView(
                                            current_course_name:
                                                current_course_name,
                                            current_courseRole:
                                                current_courseRole,
                                            current_end_date: current_end_date,
                                            current_start_date:
                                                current_start_date,
                                            current_room_number:
                                                current_room_number,
                                            current_description:
                                                current_description,
                                            ttableentryid: ttableentryid,
                                            current_ttabledate:
                                                current_ttabledate,
                                          ),
                                        ),
                                      );
                                    }),
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
