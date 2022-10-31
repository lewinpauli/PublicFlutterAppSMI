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

//// I currently dont know how to implement the following: (including required fields and named parameters)

// class CustomSnackbar extends SnackBar {
//   const CustomSnackbar({Key? key, required this.text, this.backgroundColor, this.icon,  }) : super(key: key);
//   //only text is required default for backgroundColor is red
//   //default for icon is Icons.error_outline (exclamation mark)

//   final Color? backgroundColor; // the ? says that the backgroundColor is optional / can be null
//   final IconData? icon; // the ? says that the icon is optional / can be null
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return SnackBar(
//       backgroundColor: backgroundColor ?? Colors.red, //inserting backgroundColor
//       shape: RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(20.0)),
//       behavior: SnackBarBehavior.floating,
//       content: Row(
//         children: <Widget>[

//           Icon(
//             icon ?? Icons.error_outline, //inserting icon value
//             color: Colors.white,
//           ),

//           const SizedBox(width: 10), // for some space between text and icon

//           Text(text), //inserting text
//         ],
//       )

//     );

//   }

// }
