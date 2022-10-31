import 'package:SMI/chat/views/chat_views_util.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class MyTheme with ChangeNotifier {
  static bool _isDark = false;

  ThemeMode currentTeme() {
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class AppTheme {
  get darkTheme => ThemeData(
      primarySwatch: Colors.teal,
      backgroundColor: Colors.grey[850],
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      shadowColor: Colors.black,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.teal,
        onPrimary: Colors.white,
        secondary: Colors.teal,
        background: Colors.black,
        onError: Colors.red,
        error: Colors.red,
        surface: Colors.red,
        onBackground: Colors.teal,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.teal,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]),
      brightness: Brightness.dark,
      canvasColor: Colors.grey[900],
      primaryColor: Colors.teal,
      checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all<Color>(Colors.black),
          fillColor: MaterialStateProperty.all<Color>(Colors.teal)));

  get lightTheme => ThemeData(
        primarySwatch: Colors.deepPurple,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.5),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.deepPurple,
          onPrimary: Colors.black,
          secondary: Colors.deepPurple,
          background: Colors.black,
          onError: Colors.red,
          error: Colors.red,
          surface: Colors.red,
          onBackground: Colors.deepPurple,
          onSecondary: Colors.white,
          onSurface: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.deepPurple,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        )),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]),
        brightness: Brightness.light,
        canvasColor: Colors.white,
        primaryColor: Colors.deepPurple,
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all<Color>(Colors.white),
          fillColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
        ),
      );
}
