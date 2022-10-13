import 'package:flutter/material.dart';

//source https://stackoverflow.com/questions/60319051/how-to-create-and-use-snackbar-for-reuseglobally-in-flutter

class CustomSnackbar {
  CustomSnackbar._();
  static buildSnackbar(
      BuildContext context, String text, IconData? icon, Color? color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: color ?? Colors.red, //inserting backgroundColor
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: <Widget>[
            Icon(
              icon ?? Icons.error_outline, //inserting icon value
              color: Colors.white,
            ),

            const SizedBox(width: 10), // for some space between text and icon

            Text(text), //inserting text
          ],
        )));
  }
}