// ignore_for_file: unused_import

import 'package:SMI/chat/views/group_rooms_view.dart';
import 'package:SMI/chat/views/direct_rooms_view.dart';
import 'package:SMI/chat/views/direct_users_view.dart';
import 'package:SMI/views/lecturer_calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:SMI/views/student_calendar_view.dart';
import 'package:SMI/views/sql_room_view.dart';
import 'package:SMI/views/bluetooth_view.dart';
import 'package:SMI/views/firebase_room_view.dart';
import 'package:SMI/views/settings_view.dart';
import 'package:SMI/views/lecturer_attendance_view.dart';
import 'package:flutter/services.dart'; // needed for SystemUiOverlayStyle.dark
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:universal_io/io.dart';

//the is the start page after the login
//here only the bottom navbar is defined and the clicked pages/views will be inserted

class LecturerRedirectView extends StatefulWidget {
  const LecturerRedirectView({Key? key}) : super(key: key);

  @override
  State<LecturerRedirectView> createState() => _LecturerRedirectViewState();
}

class _LecturerRedirectViewState extends State<LecturerRedirectView> {
  int _currentViewIndex = 0;
  final viewList = [
    const LecturerCalendarView(),
    const GroupRooms(),
    const DirectMessagesView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      //making the icons in status bar dark
      value: SystemUiOverlayStyle.dark, //making the icons in status bar dark

      child: Scaffold(
        body: viewList[
            _currentViewIndex], //the other views/pages will be inserted here

        //bottom navigation bar
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding: Platform.isIOS
                ? const EdgeInsets.only(
                    top: 10, bottom: 20, right: 10, left: 10)
                : const EdgeInsets.all(
                    10), //when Plattform = iOS, bottom padding will be increased by 10 because of bottom line navigation bar in iOS
            child: GNav(
              gap: 8, //gap between text and symbols
              padding: const EdgeInsets.only(
                  right: 20,
                  left: 20,
                  top: 10,
                  bottom: 10), //for size of the bottom navigation bar
              tabActiveBorder: Border.all(
                  color: Colors.black, width: 1), //border of active tab
              onTabChange: (index) {
                setState(() {
                  _currentViewIndex = index;
                });
              },
              tabs: const [
                GButton(icon: Icons.calendar_month_outlined, text: 'Calendar'),
                GButton(icon: Icons.people_alt_outlined, text: 'Groups'),
                GButton(icon: Icons.chat_bubble_outline, text: 'Messages'),
                GButton(icon: Icons.settings_outlined, text: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
