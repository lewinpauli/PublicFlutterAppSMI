# SMI Flutter App

This is the App for the "Saint Martin's Institute of Higher Education",
to automatically track the attendance of the students in their lesson via bluetooth and display their schedule (right now works with a button, but later on should scan in the background).
Works on iOS and Android.
Chat is implemented with which the school can send notifications to their students.
Right now its possible to login as an Administrator, Student or Lecturer/Teacher.

Admins can choose if they want to login as Student or Lecturer.

Students can see their schedule and can register automatically via bluetooth as attendant.
Student Login:


https://user-images.githubusercontent.com/99770169/194829169-8a967489-ab43-4e39-817b-fdf8c49e01e3.mp4



Lecturers can see their schedule as well and change the attendance state of the students manually.
Lecturers Login:



https://user-images.githubusercontent.com/99770169/194829625-7ef2fffa-a7a6-4fac-b43c-8e84dff95f61.mp4





Documentation: https://docs.google.com/document/d/1pdgyBKCo6_wXYjqbS6IkUrQ24YFgNqQo7sHWawcGig8/ 

Trello board: https://trello.com/b/o0Gwjb2B/flutter-app-saint-martins-malta



## Tech Information

This App has been developed from the ground up using the Cross Platform App Framework "Flutter"

The data from the school is in SQL and was provided via php rest api during the development of the app

The app has been tested on real iOS and Android devices.

Major Plugins that were used (for more details take a look at pubspec.yaml):

firebase* for google login and chat integration

flutter_blue_plus for bluetooth scans

flutter_firebase_chat_core & flutter_chat_ui flyer chat plugin

google_nav_bar for the bottom navigation bar

get to handle variables across views
