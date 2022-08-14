import 'package:flutter/material.dart';

ThemeData get theme {
  return ThemeData(
    primarySwatch: Colors.deepPurple,
    colorScheme: ThemeData().colorScheme.copyWith(
          secondary: Colors.blueGrey,
        ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: ThemeData().textTheme.copyWith(
          bodyText1: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          bodyText2: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
  );
}
